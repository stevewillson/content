#!/bin/bash

#######################################
#
# Steve Willson
# 5/7/18
# gen_blog.sh
# script to generate a blog from a
# collection of .adoc files
#
#######################################

DEBUG=0

# Blog title, subtitle, and author
BLOG_TITLE="willson.tk"
BLOG_SUBTITLE="because when all is said and done, more is said than done..."
AUTHOR="Steve Willson"

# Contact info
TWITTER="https://twitter.com/stevewillson"
WEBSITE="https://willson.tk"
GITHUB="https://github.com/stevewillson"
EMAIL="steve.willson@gmail.com"

# Blog locations
GIT_CONTENT="git@github.com:stevewillson/content.git"
CONTENT_DIR="/home/user/git/content/in_progress/gen_blog/content"
OUTPUT_DIR="/home/user/git/content/in_progress/gen_blog/output"
BASE_DIR="/home/user/git/content/in_progress/gen_blog"
STYLESHEET="boot-cyborg.css"

# Functions to create the blog
create_output_dir()
{
    mkdir -p $OUTPUT_DIR
}

# Get or update the content from the git server
clone_or_update_content()
{
    {
    # attempt to clone the repo
        [ "$DEBUG" -eq 1 ] && echo "Cloning content"
        git clone $GIT_CONTENT $CONTENT_DIR
    } || {
    # if the clone fails, cd into the CONTENT_DIR and do a git pull
        [ "$DEBUG" -eq 1 ] && echo "Cloning failed, doing a pull"
        cd $CONTENT_DIR
        git pull
    }
}

create_index_adoc()
{

# generate the index.adoc file
# use the variables to populate the page

cat << EOF > $OUTPUT_DIR/index.adoc

= $BLOG_TITLE
$AUTHOR $EMAIL
:imagesdir: images
:stylesheet: $CONTENT_DIR/$STLESHEET

$BLOG_SUBTITLE

image:GitHub-Mark-Light-64px.png[link="$GITHUB"]
image:Twitter_Social_Icon_Circle_White_64px.png[link="$TWITTER"]
image:at_sign_white_64px.png[link="mailto:$EMAIL"]

'''

EOF

}

copy_images()
{
    cp -r $CONTENT_DIR/images/ $OUTPUT_DIR
}

copy_stylesheet()
{
    cp -r $CONTENT_DIR/$STYLESHEET $OUTPUT_DIR
}

convert_content_adoc_to_html()
{
    find $CONTENT_DIR -path "*.adoc" | while read adoc; do asciidoctor $adoc -D $OUTPUT_DIR; done
}

display_web_page()
{
    firefox index.html
}

publish_web_page()
{
    cp $OUTPUT_DIR/* /var/www/html/
}

generate_index_html()
{
    asciidoctor $OUTPUT_DIR/index.adoc
}

generate_file_info_list(){

    rm -f $BASE_DIR/file_info.log

    find $CONTENT_DIR -path "*.adoc" | while read adoc; do 
    FULLPATH=$(echo $adoc | sed 's/\.[^.]*$//');
    FILENAME=$(basename $FULLPATH);
# some files don't have a revdate, it should be added by the blog author, if there is not revdate, assume that it was made 2 years ago, this should put the post at the bottom of the index
    DATESTR=$(grep revdate $OUTPUT_DIR/$FILENAME.html | cut -d">" -f2 | cut -d"<" -f1)
    if [ -z "$DATESTR" ]; then 
        DATE=$(date --date="2 years ago" +"%x")
    else
        DATE=$(date --date="$DATESTR" +"%x")
    fi
    TIMESTAMP=$(date --date="$DATE" +"%s");
    WORDS=$(wc -w $adoc | cut -d" " -f1);
    TIME_TO_READ_MINUTES=$(( (199 + $WORDS) / 200));
    # associative arrays aren't working for me...
    # generate a file with 
    echo "$FILENAME,$TIMESTAMP,$DATE,$WORDS,$TIME_TO_READ_MINUTES" >> $BASE_DIR/file_info.log
    #FILEDATE["$FILENAME"]="$TIMESTAMP"
    if [ $DEBUG -eq 1 ]; then  
        echo "----------------------------"
        echo "Filename: $FILENAME"
        echo "Date: $DATE"
        echo "Timestamp: $TIMESTAMP"
        echo "Words: $WORDS"
        echo "Time to read: $TIME_TO_READ_MINUTES minute(s)"
        echo;
    fi
    done
}


add_teasers_to_index()
{
    sort -r -t, -k2 $BASE_DIR/file_info.log > $BASE_DIR/sort_file.log
    for FILE in $(cat $BASE_DIR/sort_file.log); do
    FILENAME=$(echo $FILE | cut -d"," -f1);
    TIMESTAMP=$(echo $FILE | cut -d"," -f2);
    DATE=$(echo $FILE | cut -d"," -f3);
    WORDS=$(echo $FILE | cut -d"," -f4);
    TIME_TO_READ_MINUTES=$(echo $FILE | cut -d"," -f5);
   
    if [ $DEBUG -eq 1 ]; then  
        echo "----------------------------"
        echo "$FILE"
        echo "ADDING TEASER TEXT"
        echo "Filename: $FILENAME"
        echo "Date: $DATE"
        echo "Timestamp: $TIMESTAMP"
        echo "Words: $WORDS"
        echo "Time to read: $TIME_TO_READ_MINUTES minute(s)"
        echo;
    fi
   
    FULLPATH=$(find $CONTENT_DIR -name "$FILENAME.adoc")
    TITLE=$(grep '<title>' $OUTPUT_DIR/$FILENAME.html | cut -d'>' -f2 | cut -d'<' -f1)
    CONTENT=$(head -n 20 $FULLPATH)    

cat << EOF >> $OUTPUT_DIR/index.adoc

== link:$OUTPUT_DIR/$FILENAME.html[$TITLE]
Date: $DATE +
$TIME_TO_READ_MINUTES minutes

EOF

#cat $FULLPATH | head -n 20 >> $OUTPUT_DIR/index.adoc

    done

}

generate_blog()
{
    create_output_dir
    [ "$DEBUG" -eq 1 ] && echo "Cloning or updating content"
    clone_or_update_content
    copy_images
    copy_stylesheet
    [ "$DEBUG" -eq 1 ] && echo "Generating web page"
    convert_content_adoc_to_html
    generate_file_info_list
    create_index_adoc
    # add 'teasers' from the entries to the web page
    add_teasers_to_index

    generate_index_html
}

generate_blog

