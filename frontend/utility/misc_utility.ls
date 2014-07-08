# Generate random strings, useful for ID's and such
random_string = (numchars) !->
    ret = ""
    pool = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    for i from 0 to numchars by 1
        ret += pool.charAt (Math.floor ((Math.random!) * pool.length))
    return ret
