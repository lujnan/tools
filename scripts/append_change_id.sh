
# for macosx.

tmp=$(mktemp -q /tmp/gm.XXXXXX)
hook=$(pwd)/$(git rev-parse --git-dir)/hooks/commit-msg
#git filter-branch -f --msg-filter "cat > $tmp; \"$hook\" $tmp; cat $tmp" origin/master..master
git filter-branch -f --msg-filter "cat > $tmp; \"${hook}\" $tmp; cat $tmp" 

rm -rf ${tmp}
