#!/bin/bash
# -- create-ssh-hosts-links.sh -------------------------------------------------
#
# This program comes with no warranty. Use at your own risk.
# You have been warned. (That said, it works well for me :)
#
# Copyright (c) 2012 ed.o
# include 'MIT-License.txt'
#
# See https://github.com/copperwalls/create-ssh-hosts-links
#
# ------------------------------------------------------------------------------
shopt -s -o nounset

# Using Bash; so assume ~/.bash_profile is where we set PATH
declare -rx PROFILE="$HOME/.bash_profile"

# Where we will create our links
declare -rx SSH_HOSTS_ALIAS_DIR="$HOME/bin/ssh-hosts"

# The length of the shortened link; suit to taste
declare -rx SHORTENED_NAME_LENGTH=3

# Default ssh_config file
declare -x CONFIG_PATH_FILENAME="$HOME/.ssh/config"

# Alternative config file pass as the first parameter (full path)
# e.g., ./create-ssh-hosts-links.sh /path/to/other-config-file-here
# NOTE: Not meant to work with path/filenames with spaces in it
[[ $# -ge 1 ]] && [[ -f "$1" ]] && CONFIG_PATH_FILENAME="$1"

# The script we’re going to create (where the links will point to)
declare -rx SSH_FOR_SCRIPT=$HOME/bin/ssh-for-$(basename $CONFIG_PATH_FILENAME)

# The contents of that script we’re going to create; clever eh? ;)
declare -rx NEW_SCRIPT_LINE="ssh -F '$CONFIG_PATH_FILENAME' \$SSH_HOST \$*"

# Extract all the names of the Host(s) found in the config file (except last)
declare -rx SSH_HOSTS=$(grep ^Host "$CONFIG_PATH_FILENAME" | sed '$d' | sort | \
    awk -F' ' '{ print $NF }')

# See if we extracted the Host(s) properly; abort otherwise
if [[ -z "$SSH_HOSTS" ]]; then
cat <<EOE

Error: No Host(s) found in '$CONFIG_PATH_FILENAME'
Are you sure the format of that config file is correct?
See the bundled config.sample for ideas. For more info:

    man 5 ssh_config
EOE
    exit 192
fi

# This is where the real party starts

# Waste some CPU cycles; find out the length of the longest hostname
let LONGEST_NAME=0
for SSH_HOST in $SSH_HOSTS
do
    [[ $LONGEST_NAME -lt ${#SSH_HOST} ]] && let LONGEST_NAME=${#SSH_HOST}
done

# If it doesn’t exist, create the directory where we’ll put our links
[[ -d "$SSH_HOSTS_ALIAS_DIR" ]] || mkdir -p "$SSH_HOSTS_ALIAS_DIR"

# Our new script—where all the magic happens :)
(
cat <<EOE
#!/bin/bash
# -- ssh-for-* -----------------------------------------------------------------
#
# This program comes with no warranty. Use at your own risk.
# You have been warned. (That said, it works well for me :)
#
# Copyright (c) 2012 ed.o
# include 'MIT-License.txt'
#
# See https://github.com/copperwalls/create-ssh-hosts-links
#
# ------------------------------------------------------------------------------
shopt -s -o nounset

# The link which called this script
SSH_HOST=\$(basename \$0)

# Where does it link to?
LINKS_TO=\$(basename \$(readlink \$0))

# If the link is just a shortened version of a hostname, we’ll use the original
# instead since it’s the one which points to an entry in the ssh config file
[[ \${LINKS_TO:0:8} == 'ssh-for-' ]] || SSH_HOST=\$LINKS_TO

# Got the hostname; now we can connect
$NEW_SCRIPT_LINE

EOE
) > $SSH_FOR_SCRIPT

# Make sure the new script is executable
[[ -x $SSH_FOR_SCRIPT ]] || chmod +x $SSH_FOR_SCRIPT

# Function to call to find best suffix available
find_best_suffix () {
    # Check whether there isn’t any command collision
    which $1 > /dev/null 2>&1
    [[ $? -ne 0 ]] && [[ ! -h "$SSH_HOSTS_ALIAS_DIR/$1" ]] && return 0
    # Collision! Let’s find the best suffix for the new link/command
    let SUFFIX=2
    while true; do
        which $1$SUFFIX > /dev/null 2>&1
        if [ $? -eq 0 ] || [ -h "$SSH_HOSTS_ALIAS_DIR/$1$SUFFIX" ]; then
            let SUFFIX+=1
            continue
        fi
        return $SUFFIX
    done
}

# Function to call to add padding (for pretty display)
display_padded_hostname() {
    # $1 = hostname/link
    PADDED_NAME=$(echo "$1" | sed -e :a -e "s/^.\{1,$LONGEST_NAME\}$/& /;ta")
    echo -n "$PADDED_NAME"
}

# Now let’s create all the links to Host(s) found in the config file
for SSH_HOST in $SSH_HOSTS
do
    # Skip Host(s) which links already exists
    if [[  -h "$SSH_HOSTS_ALIAS_DIR/$SSH_HOST" ]]; then
        display_padded_hostname $SSH_HOST
        echo '<- SKIPPED: Link already exists'
        continue
    fi
    # Skip Host(s) which collides with existing link/command as well
    which $SSH_HOST > /dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        display_padded_hostname $SSH_HOST
        echo '<- SKIPPED: Link/command with the same name exists!'
        continue
    fi
    # Link not found; let’s create it ...
    display_padded_hostname $SSH_HOST
    SSH_HOST_ALIAS="$SSH_HOSTS_ALIAS_DIR/$SSH_HOST"
    ln -s "$SSH_FOR_SCRIPT" "$SSH_HOST_ALIAS"
    echo -n '<- Created. '
    # ... and create a shortened alias for a more faster typing
    # But first let’s see if we’re not making something short longer ;)
    SHORTENED_NAME=${SSH_HOST:0:$SHORTENED_NAME_LENGTH}
    if [[ ${#SSH_HOST} -lt $SHORTENED_NAME_LENGTH+1 ]]; then
        echo 'But no shorter name (it is already short)'
        continue
    fi
    # Then let’s find out if the shortened link already exists
    if [[  -h "$SSH_HOSTS_ALIAS_DIR/$SHORTENED_NAME" ]]; then
        # If it does exists, see if it’s pointing to the present host link
        if [[ $(readlink "$SSH_HOSTS_ALIAS_DIR/$SHORTENED_NAME") == \
            "$SSH_HOSTS_ALIAS_DIR/$SSH_HOST" ]]; then
            echo "Shorter name: $SHORTENED_NAME"
            continue
        fi
    fi
    # OK, we need to create a shortened form for this Host
    find_best_suffix $SHORTENED_NAME
    BEST=$?
    [[ $BEST -ne 0 ]] && SHORTENED_NAME=$SHORTENED_NAME$BEST
    ln -s "$SSH_HOST_ALIAS" "$SSH_HOSTS_ALIAS_DIR/$SHORTENED_NAME"
    echo "Shorter name -> $SHORTENED_NAME"
done

# Make sure we can execute those links
[[ -n "$(grep PATH.$SSH_HOSTS_ALIAS_DIR $PROFILE)" ]] ||
    echo "export PATH=\"\$PATH:$SSH_HOSTS_ALIAS_DIR\"" >> $PROFILE &&
    . $PROFILE

# All done! No need to type “ssh hostname”.
# From now on, just the hostname or the shortened form :)

#
# Happy hacking!
# ---------------------------------------------------------------------- ed.o --
