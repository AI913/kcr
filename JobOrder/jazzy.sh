
if [ $# = 0 ]; then
    bundle exec jazzy --output docs/Presentation --module JobOrder.Presentation
    bundle exec jazzy --output docs/Domain --module JobOrder.Domain
    bundle exec jazzy --output docs/API --module JobOrder.API
    bundle exec jazzy --output docs/Data --module JobOrder.Data
    bundle exec jazzy --output docs/Utility --module JobOrder.Utility
elif [ $1 = "Presentation" ] || [ $1 = "Domain" ] || [ $1 = "API" ] || [ $1 = "Data" ] || [ $1 = "Utility" ]; then
    bundle exec jazzy --output docs/$1 --module JobOrder.$1
else
    echo "Invalid argument!!"
fi
