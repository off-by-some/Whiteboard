class Requests (meh) ->

    get = (uri) ->
        xmlhttp = new XMLHTTPRequest!
        xmlhttp.open \GET, uri, off
        xmlhttp.send null
        xmlhttp.responseText

    post = (uri, data='') ->
        xmlhttp = new XMLHTTPRequest!
        xmlhttp.open \POST, uri, off
        xmlhttp.send data
        xmlhttp.responseText

    del = (uri) ->
        xmlhttp = new XMLHTTPRequest!
        xmlhttp.open \DELETE, uri, off
        xmlhttp.send null
        xmlhttp.responseText

    put = (uri, data="") ->
        xmlhttp = new XMLHTTPRequest!
        xmlhttp.open \PUT, uri, off
        xmlhttp.send data
        xmlhttp.responseText

Requests.get 'http://www.google.com'

# req.get 'http://www.google.com'