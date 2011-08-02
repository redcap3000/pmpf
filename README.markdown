pmpf
====
Ronaldo Barbachano
http://myparse.org
July, 2011
AGPL

*Postgres powered CMS based on myparse.*

**Object oriented (inherited) template design.**

**Automatic template/view versioning**

**Multidimensional array fields**

**Corelated group management.**

**Flexible and extensible permissions systems**

**Simple database access via custom SQL functions.**

Goals:
======
Create an extremely fast, secure, and rhobust cms to take full advantage of SQL and postgres, and allows simple and powerful ways for developers to port to any language.

Provide specialized functions to simplify syntax in the database and create string /array processors where the database leaves us hanging in multiple web scripting languages.

Handle sessions, and logins via the database.

Provide rhobust versioning, quickly switch between available versions.

Allow full control over a page's output header (create XML/RSS/JSON whatever types of documents your web server supports) mostly via the database

To put as much of a web applications functionality inside of the database with triggers, functions and advanced table design.

create functions to modify and extend table/type structures

Installation:
=============
For now installation only install base tables, but does not address any programming languages. A php library is in the works, check pgdb for more info.

Simply create a database, connect to it and import all files ending in .sql in the order below :: Order is ***important***!

<pre>
psql
CREATE DATABASE 'pmpf';
\c pmpf;
\i pmpf/sql/types.sql;
\i pmpf/sql/tables.sql;
\i pmpf/sql/rules.sql;
\i pmpf/sql/functions.sql;

</pre>

Usage
=====
Basically pmpf sorts and organizes html data like myparse. Check out myparse.org. An interface (in php) is in the works, but for the time being you'll need to manually
edit the records in the database.

Next to select a url to display simply make a SQL statement 

<pre>
SELECT * from get_url('homepage');
</pre>

This will select blocks that have a url that matches what is entered and return two columns, one of the data contained in field b_option, and an array (which will appear as a coded string) that contains a arrays of arrays, each inside array only containing two values - the first the key or attribute name, the second the value.

Versioning
==========
To select a single version of a block you may use the SQL function 'get_blocks_version()', provided
the number of the version you would like to select, and the ID of the block.

***Example Use***
<pre>
SELECT * from get_blocks_version(1,2);
</pre>
This will select version '1' of block id '2'.

Versioning is automatically enabled for table 'mp_blocks'. When a new record is created in this database, another is created in the versions database.
Each time the mp_blocks record is modified (and different from the previous version) a new copy of the row is stored to the 'mp_versions' table
as a coded string inside the a single column in a single row that refers to the block being edited.

Why? So a new record is not created each time a change is made. Also stored in this column is a timestamp of when the change was made.

A php web interface is in the works, planned is the ability to switch between different versions, and delete versions.
