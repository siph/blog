# Working with JSON in the command line with `jq`
JSONs versatility makes it a great choice for many things beyond web communications. Configuration files and logging
files are two things that often are written in, or contain JSON. Working with these files using traditional tools like
`awk` and `sed` is cumbersome and frustrating. This is where [`jq`](https://github.com/stedolan/jq) comes in.

## What is `jq`?
`jq` is a JSON processing tool that uses a very high level, purely functional language to query, mutate, and create
JSON. Utilizing the familiar concepts of pipes, filters, and streams; `jq` accepts expressions written in the JSON-like
syntax unique to `jq`.

## Examples
`jq` can accept either a file that contains the JSON, or JSON piped through stdin. This allows you to do pretty cool
things like pipe the body of a `curl` request into `jq`, apply some business logic to derive a new JSON body, and pipe
that body back into another `curl` request to send to a remote server. The following examples are going to be ran
against some made-up status style JSON and fed in as a program argument. You can use [jqplay](https://jqplay.org/)
to try out `jq` in the browser and to help build complex commands.
```json
# config.json
{
    "version": "22.04",
    "dimensions": {
        "width": 1920,
        "height": 1080
    },
    "devices": [
        {
            "id": 22,
            "state": "on",
            "group": 0,
            "status": "OK"
        },
        {
            "id": 422,
            "state": "off",
            "group": 0,
            "status": "OK"
        },
        {
            "id": 702,
            "state": "off",
            "group": 99,
            "status": "FAILED"
        }
    ]
}
```

### Read Property
Expressions are passed into `jq` as a string. Because we are eventually going to be using double quotes to work with
nested strings, we can wrap everything in single quotes to avoid having to escape every quotation.

The dot operator is used to access the top-level entity within the scope. This gives us access the version property.
```bash
jq '.version' config.json

# output:
"20.04"
```

The truncate tool (`tr`) can be used to clean up the quotes
```bash
jq '.version' config.json | tr -d /"

# output:
20.04
```

Nested properties can be accessed like expected.
```bash
jq '.dimensions.width' config.json

# output:
1920
```

### Arrays
Arrays can be iterated over by calling the array directly.
```bash
jq '.devices[]' config.json

# output:
{
    "id": 22,
    "state": "on",
    "group": 0,
    "status": "OK"
}
{
    "id": 422,
    "state": "off",
    "group": 0,
    "status": "OK"
}
{
    "id": 702,
    "state": "off",
    "group": 99,
    "status": "FAILED"
}
```

Arrays can also be indexed like expected.
```bash
jq '.devices[0]' config.json

# output:
{
    "id": 22,
    "state": "on",
    "group": 0,
    "status": "OK"
}
```

`jq` also supports slicing of both arrays and strings.
```bash
jq '.devices[:-1]' config.json

# output:
{
    "id": 22,
    "state": "on",
    "group": 0,
    "status": "OK"
}
{
    "id": 422,
    "state": "off",
    "group": 0,
    "status": "OK"
}
```

### Pipes
The real power of `jq` starts with the pipe operator. Properties can be selected and then piped into the next expression.
The above example of iterating over an array can also be written using the pipe operator.
```bash
jq '.devices | .[]' config.json

# output:
{
    "id": 22,
    "state": "on",
    "group": 0,
    "status": "OK"
}
{
    "id": 422,
    "state": "off",
    "group": 0,
    "status": "OK"
}
{
    "id": 702,
    "state": "off",
    "group": 99,
    "status": "FAILED"
}
```

Accessing the `state` property of each object.
```bash
jq '.devices | .[] | .state' config.json

# output:
"on"
"on"
"off"
```

### Filtering
`jq` has a number of built-in functions, one of which is [`select`](https://stedolan.github.io/jq/manual/#select(boolean_expression)).
`select` accepts a boolean expression and returns if the condition evaluates to true.

Selecting all devices that are disabled and do not have a `status` of OK.
```bash
jq '.devices | .[] | select(.state=="off") | select(.status != "OK")' config.json

# output:
{
    "id": 702,
    "state": "off",
    "group": 99,
    "status": "FAILED"
}
```

### Regex
Instead of comparing strings directly, `jq` has several regex functions with the simplest being `test`, which returns a
boolean if the input string matches the regular expression. The above filter can be rewritten using `test`.
```bash
jq '.devices | .[] | select(.state|test("off")) | select(.status|test("^((?!OK).)*$"))' config.json

# output:
{
    "id": 702,
    "state": "off",
    "group": 99,
    "status": "FAILED"
}
```

### Building JSON
`jq` also lets you mutate and create JSON. Maybe you want to build a new JSON object using only two fields from the
source JSON. You can assign the parent property to a variable so that it is still accessible in the nested scope.
```bash
 jq '.version as $version | .devices | .[] | {device_id: .id, version: $version}' config.json

# output:
{
  "device_id": 22,
  "version": "22.04"
}
{
  "device_id": 422,
  "version": "22.04"
}
{
  "device_id": 702,
  "version": "22.04"
}
```

You can wrap the expression in square brackets to collect the objects into an array.
```bash
jq '[.version as $version | .devices | .[] | {device_id: .id, version: $version}]' config.json

# output:
[
  {
    "device_id": 22,
    "version": "22.04"
  },
  {
    "device_id": 422,
    "version": "22.04"
  },
  {
    "device_id": 702,
    "version": "22.04"
  }
]
```

Lets take the `dimensions` object and squash it into a new string to add to our objects. This time instead of
assigning a property to a variable, an entire JSON object is created to be referenced later. Parenthesis must be used to
group expressions together. The full expression is starting to get quite long so it's now broken up into multiple lines
and indented to be more readable.
```bash
 jq '
  [
    {
      version: .version,
      dimensions: ((.dimensions.width|tostring) + "x" + (.dimensions.height|tostring))
    }  as $extras
    | .devices
    | .[]
    | {
        device_id: .id,
        version: ($extras|.version),
        dimensions: ($extras|.dimensions)
      }
  ]' config.json

# output:
[
  {
    "device_id": 22,
    "version": "22.04",
    "dimensions": "1920x1080"
  },
  {
    "device_id": 422,
    "version": "22.04",
    "dimensions": "1920x1080"
  },
  {
    "device_id": 702,
    "version": "22.04",
    "dimensions": "1920x1080"
  }
]
```

## Conclusion
This guide doesn't cover the full depth of `jq` but should be more than enough to get started doing some pretty cool
things. I've only just discovered `jq` but I can already see so many ways that it can benefit my workflow. There are
more features included in `jq` such as function definitions, conditionals, comparisons, and modification assignment
operators. You can find overviews of all these features and more in the `jq` [manual](https://stedolan.github.io/jq/manual/).
