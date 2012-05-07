faster-ssh-logins
=================

Turbo fast SSH logins.

Type “ssh hostname” no more. Just the hostname or a shortened version of it and you’ll be logged in to your SSH server in no time!

In other words: I don’t like typing long SSH commands. If I can shorten it, I will :)

Requirements
------------

This will work on any OS with Bash and OpenSSH installed. (e.g. [Mac OS X](http://www.apple.com/macosx/), GNU/Linux) This will probably work on Windows too (inside [Cygwin](http://cygwin.com/)) but I don’t usually use and won’t recommend Windows ;)

How
---

Just clone/download the files then run:

    ./create-ssh-hosts-links.sh

or,

    ./create-ssh-hosts-links.sh /path/to/alternative/config/file

That script will:
-----------------

1. Scan your [~/.ssh/config](http://www.openbsd.org/cgi-bin/man.cgi?query=ssh_config) file (You do have one, right? right?)
2. Create a “bin” directory in your $HOME directory (if it doesn’t exist)
3. Create an “ssh-hosts” directory in that “bin” directory (if it doesn’t exist)
4. Creat a script in ~/bin named “ssh-for-something-something”
5. Create links/aliases in ~/bin/ssh-hosts (up to two for each hosts)
6. Add an `export PATH` command in your ~/.bash_profile (if it’s not there yet)
7. Make your life easier

Read the source code (of course!) for more details. (I made it as readable as possible.)

Sample Output
-------------

### Successful Link Creation ###

    apple     <- Created. Shorter name -> app

Perfect. Now you can just type “apple” or “app” to access the “apple” server.

    cranberry <- Created. Shorter name: cra

Same as above.

    fig       <- Created. But no shorter name (it is already short)>

Default length for “shorter name” is three characters.

    mango     <- Created. Shorter name -> man2

Obviously, “[man](http://en.wikipedia.org/wiki/Man_page)” is already taken. Type “man2” instead.

TIP: Change the value of “SHORTENED_NAME_LENGTH” inside the script to change the length of the “shorter name”.

### Errors and Warnings ###

    blueberry <- SKIPPED: Link already exists

Remove the link first if you want to recreate it.

    test      <- SKIPPED: Link/command with the same name exists!>

System command. Can’t make a link for it. Edit your config file and change the value of “Host” to another name. Then run the script again.

    grep: /Users/ed.o/.ssh/config: No such file or directory

Make sure the file exist. Copy and edit the bundled config.sample file if you don’t have one.

    Error: No Host(s) found in '/Users/ed.o/.ssh/config'
    ...

Make sure the format of your config file is correct. See bundled config.sample file for, um, an example.


Included Files
--------------

- create-ssh-hosts-links.sh — The script and links generator (Bash script)
- config.sample — Sample ~/.ssh/config file; `man 5 ssh_config` for details
- README.md — This very document
- MIT-License.txt — License file (Contents also found at end of this document)

Notes
-----

### config File Format ###

The program expects a config file similar to the bundled config.sample file. It will not create a link for the last, default entry.

### To Uninstall ###

To “uninstall” (remove the generated files, etc.) just:

1. Delete the entire “ssh-hosts” directory inside $HOME/bin
2. Delete the scripts name “ssh-for-something-something” inside $HOME/bin
3. Delete that “bin” directory IF it is empty
4. Delete the line “export PATH=$PATH:something-something-here/ssh-hosts”
5. Delete these files you’ve downloaded

### Caveat ###

Obviously, we cannot create a [symbolic] link with a name that clashes with an OS command or another link. If you have an SSH server named “git”, and if you have a “git” command (executable in your $PATH), this program will NOT create the SSH Host’s link for that server. Change the Host’s name in your config file then run the script again.

The program is “intelligent” enough though to create shorter links for servers with similar names. (e.g., serverupstairs, serverdownstairs, serveroutside will have shorter links ser, ser2, and ser3 respectively)

TODO
----

Decide if it’s a good idea to recreate existing links instead of skipping them.

Contributing
------------

It’s a small script. I’m sure there’s a big room for improvement. If you can improve it, I encourage you to do so. Of course, you don’t have to get your hands dirty. If you have an idea, just let me know. If I see fit to add it, I’ll even write the code myself.

License
-------

Copyright (c) 2012 ed.o

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

