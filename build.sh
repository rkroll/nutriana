#!/bin/sh

# The SQL files are generated via Perl, so make sure it's installed.
PERL=`which perl`
if [ "$PERL" == "" ]; then echo "Please install Perl" ; exit 1 ; fi

# Process all nutrient databases included.
for NUTDBDIR in `find . -type d -depth 1`; do
    # Extract nutrient dabatase identifier.
    NUTDBID=`expr "$NUTDBDIR" : "\./\(.*\)"`

    # Ignore .git dir.
    if [ "$NUTDBID" == ".git" ]; then continue; fi

    # Check that the data files do not contain any special characters.
    # Because in shell scripts `file $NUTDBID/*.txt` does not preserve newlines,
    # defer to Perl for this.
    $PERL ./check_data_files.pl $NUTDBID

    # The Perl modules indicate the databases to generate SQL for.
    for PMFILE in `find . -type f -name \*.pm`; do
        # Extract dabatase identifier.
        RDBMSID=`expr "$PMFILE" : "\./\(.*\).pm"`
        # Convert outfile to lowercase.
        OUTFILE="$(tr [A-Z] [a-z] <<< $NUTDBID"_"$RDBMSID.sql)"

        # Generate the SQL file for this database.
        # Make sure to add the current directory to the beginning of @INC
        # to avoid accidentally using official modules with the same name.
        $PERL -I . -M$RDBMSID ./generate_sql.pl $RDBMSID $NUTDBID > $OUTFILE

        echo "$RDBMSID file for $NUTDBID generated: $OUTFILE"
    done
done
