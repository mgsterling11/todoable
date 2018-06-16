This is an implementation of the teachable programming assignment described here:

http://todoable.teachable.tech/

It wraps the teachable todoable API in a manner that allows the user to setup/use
a simple todo application, and as such there are two resources:

- Lists
- Items

Lists have items, items can be finished, a common flow might look like:


```

Todoable.authenticate!

list = Todoable::List.new("First List Name")

# returns the sets of Todoable::Item (s) for the list
items = list.items

=> []

item = list.add_item("Feed the cat item")
list.items

=> [Todoable::Item]

item.finish()

```


Authentication:

In order to sync with the Todoable app, environmental variables must be set with your name and password:

```
export TODO_USER=<username>
export TODO_PASSWORD=<password>
```

this will print out a token which can then be added to the environment as well to prevent constant authentication calls
```
export TODO_TOKEN=<token>
```

then you must authenticate within the application:

```
Todoable.authenticate!
```


For the purposes of timeboxing, which I do fairly strictly for assignments like this. I chose to cut some scope from the gem, but in an assignment like this I like to add what I would do given more time:

- Automatically add the token on authentication to prevent the need to set the token
- Clean up the models a little better when items are added or more specifically when items are finished. I could just set the "finished_at" time to now within the gem, but that feels cheap, a better method would be to refresh the item since the app does not return the updated "finished" item, which isn't super resty
- Test all the error cases, would be just a bunch of stub responses with different errors codes
- Clean up object constructors, I don't love argument specific constructors and I'm a little sad I'm leaving it like that
- There's generally a lot of repeated code, in honor of DRY I would have liked to remove those
