class Requests (meh) ->

    get = (uri) ->
        xmlhttp = new XMLHTTPRequest!
        xmlhttp.open \GET, uri, off
        xmlhttp.send null
        xmlhttp.response-text

    post = (uri, data='') ->
        xmlhttp = new XMLHTTPRequest!
        xmlhttp.open \POST, uri, off
        xmlhttp.send data
        xmlhttp.response-text

    del = (uri) ->
        xmlhttp = new XMLHTTPRequest!
        xmlhttp.open \DELETE, uri, off
        xmlhttp.send null
        xmlhttp.response-text

    put = (uri, data="") ->
        xmlhttp = new XMLHTTPRequest!
        xmlhttp.open \PUT, uri, off
        xmlhttp.send data
        xmlhttp.response-text

Requests.get 'http://www.google.com'

# req.get 'http://www.google.com'