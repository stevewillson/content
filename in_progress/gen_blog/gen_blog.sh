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

# Blog title, subtitle, and author
BLOG_TITLE="JustDoTheThing"
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

# Functions to create the blog
create_index()
{

# generate the index.adoc file
# use the variables to populate the page

cat <<EOF > $OUTPUT_DIR/index.adoc

= $BLOG_TITLE
$AUTHOR $EMAIL
:imagesdir: images

$BLOG_SUBTITLE

image:GitHub-Mark-Light-64px.png[link="$GITHUB"]
image:Twitter_Social_Icon_Circle_White_64px.png[link="$TWITTER"]
image:at_sign_white_64px.png[link="mailto:$EMAIL"]

EOF

}


copy_images()
{
    cp -r $CONTENT_DIR/images/ $OUTPUT_DIR

}

generate_web_page()
{
    mkdir -p $OUTPUT_DIR
    create_index
    copy_images
    asciidoctor $OUTPUT_DIR/index.adoc
}


display_web_page()
{
    firefox index.html
}

publish_web_page()
{
    cp $OUTPUT_DIR/* /var/www/html/
}


clone_or_update_content()
{

    {
    # attempt to clone the repo
        echo "Cloning content"
        git clone $GIT_CONTENT $CONTENT_DIR
    } || {
    # if the clone fails, cd into the CONTENT_DIR and do a git pull
        echo "Cloning failed, doing a pull"
        cd $CONTENT_DIR
        git pull
    }
}

echo "Cloning or updating"
clone_or_update_content
echo "Generating web page"
generate_web_page


#display_web_page

# for words per minute, figure that the avg person can read 200 wpm

# 
# find /home/user/github_content/content/ -path "*.adoc" | while read adoc; do asciidoctor $adoc -D /home/user/github_content/output/ ; done
# 
# 

