local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
	s(
		"args",
		fmt(
			[[
usage_exit() {{
    echo -e "Usage: $0\n    --key value" 1>&2
    exit 1
}}

OPT=$(getopt -o h -l key:,help -- "$@")

if [ $? != 0 ]; then
    usage_exit
fi
eval set -- "$OPT"
while true
do
    case $1 in
        --key) KEY=$2 
            shift 2
            ;;
        -h | --help) usage_exit
            ;;
        --) shift
            break
            ;;
        *)
            echo "Unexpected behavior" 1>&2
            exit 1
            ;;
    esac
done
            ]],
			{}
		)
	),
}
