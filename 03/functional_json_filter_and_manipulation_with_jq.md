# Working with JSON in the command line with `jq`
JSONS versatility makes it a great choice for many things beyond web communications. Configuration files and logging
files are two things that often are written in, or contain JSON. Working with these files using traditional tools like
awk and sed is cumbersome and frustrating. This is where [`jq`](https://github.com/stedolan/jq) comes in.

## What is `jq`?
`jq` is a JSON processing tool that uses a very high level, purely functional language to query, mutate, and create JSON.
Utilizing the familiar concepts of pipes, filters, and streams; `jq` accepts expressions written in the JSON-like syntax
unique to `jq`.

## Examples
`jq` can accept either a file that contains the JSON, or JSON piped through stdin. This allows you to do pretty cool
things like pipe the body of a curl request into `jq`, apply some business logic to derive a new JSON body, and pipe that
body back into another curl request to send to a remote server. The following examples are going to be ran against some
made-up status style JSON and fed in as a program argument. You can use [jqplay.com](https://www.jqplay.org/) to try
out `jq` in the browser and to help build complex commands.
```JSON
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
Expressions are passed into `jq` as a string. Because we are eventually going to be using double quotes to build JSON
objects, we can wrap everything in single quotes to avoid having to escape every quotation.

The dot operator is used to access the top-level entity within the scope. This gives us access the version property.
```bash
jq '.version' config.json

# output:
"20.04"
```

The truncate tool (tr) can be used to clean up the quotes
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

Accessing the state property of each object.
```bash
jq '.devices | .[] | .state' config.json

# output:
"on"
"on"
"off"
```

### Filtering
`jq` has a number of built-in functions, one of which is [select](https://stedolan.github.io/jq/manual/#select(boolean_expression)).
Select accepts a boolean expression and returns when the condition evaluates to true.

Selecting all devices that are disabled and do not have a status of OK.
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
