=================
rebar_todo_plugin
=================

.. contents::

Introduction
============

The use of special comments seem to be widespread to document potential
improvements to the code. You can quite often see comments like::

    FIXME: fix the function for the case of X

    TODO: review behaviour when parameters are not what is expected

    NOTE: at this point, we only expect Y and Z

While they provide valuable information during code review, it's quite often
difficult to see the overall picture for a particular project.

This plugin helps to collect all such comments from an Erlang project in one
place so developers could review the situation and plan their work accordingly.

Installation
============

1. Download the sources::

        $ git clone git://github.com/sa2ajj/rebar_todo_plugin.git

2. Produce the binary::

        $ make

3. Install::

        $ make install

.. note::

    This command will create a directory called ``~/.rebar/plugins/ebin`` and
    put the produced ``.beam`` files there.

4. Update your environment::

        $ export ERL_LIBS="$HOME/.rebar/plugins:$ERL_LIBS"

Configuration
=============

The plugin is configured using ``todo`` item in your ``rebar.config`` file::

    {todo, [
        {name, "TODO.auto"},
        {noerror, true}
    ]}.

There are three parameters that you can change:

``name``
    name of the file to collect TODO items to (default is ``TODO``)

``wildcards``
    list of wildcards for files to search for TODO items (default is
    ``["include/*.hrl", "src/*.erl", "src/*.hrl"]``)

``noerror``
    flag to not bail out should no TODO items be found

Usage
=====

In order to start using the plugin, you must tell ``rebar`` that this plugin is
to be used::

    {rebar_plugins, [
        ...
        rebar_todo_plugin
        ...
    ]}.

and to enable the plugin itself by adding the following lines to
``rebar.config``::

    {todo, [
    ]}.

.. note::

    If the last item is not added, the plugin will do nothing.

After you have enabled the plugin, you may run::

    $ rebar todo

to produce the up to date list of TODO items defined in your source code.

The format of the produce file is very simple::

    (This file is automatically generated and will be rewritten.)

    <Kind> (<# of items of this kind>):

    <filename>:<line#>: <text>

The first line is just a reminder that the file is going to be overwritten (but
who reads that kind of reminders? :)).  And then for each kind of TODO items
(``XXX``, ``FIXME``, ``TODO``, ``NOTE``) it will produce a list (in this order)
of all found TODO items.

.. note::

    If you use ``vim`` editor, you may quickly jump between the TODO items by
    using this very simple command::

        $ vim -q TODO

Licence
=======

.. include:: LICENCE

..
    vim:tw=80
