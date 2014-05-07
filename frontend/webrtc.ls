# These help to reduce compatibility issues across browsers
PeerConnection = window.RTCPeerConnection or window.mozRTCPeerConnection or window.webkitRTCPeerConnection
IceCandidate = window.mozRTCIceCandidate or window.RTCIceCandidate
SessionDescription = window.mozRTCSessionDescription or window.RTCSessionDescription

# A list of STUN and TURN servers to aid in establishing p2p connections
# If you aren't worried about huge sdp messages, you should
# find as many of these servers as possible and put them in
# this list, because it'll make connecting a bit more reliable
server = {
    iceServers: [
        {url: "stun:23.21.150.121"},
        {url: "stun:stun.l.google.com:19302"}
    ]
}

# Don't fuck with this unless you know damn well what you're doing
# Chrome is EXTREMELY picky about what you put here
options = {
    optional: [
        {DtlsStrpKeyAgreement: true},
    ]
}

getRandomString = (n) !->
    ret = ""
    pool = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    for i from 0 til n by 1
        ret += pool.charAt (Math.floor ((Math.random!) * pool.length))
    return ret

class WebRTCManager
    # Constructor
    (our_id, websocket_url, usercallback, userclosecallback, msgcallback) ->
        @id = our_id
        # Gets called whenver we find a new user
        @new_user_callback = usercallback
        # Gets called whenver a user's connection closes
        @user_close_callback = userclosecallback
        @message_callback = msgcallback
        @peer_connections = {}
        
        @signaling_channel = new WebSocket websocket_url
        @signaling_channel.onopen = !->
            @signaling_channel.send JSON.stringify {id:@id, action:'join'}
            return
        @signaling_channel.onerror = (err) -> @error_handler err
        @signaling_channel.onmessage = (msg) -> @processSignalingMessage msg
        
    errorHandler: (err) !->
        console.log err
    
    processSignalingMessage: (msg) !->
        parsed_msg = JSON.parse msg
        
        if parsed_msg.id is not @id
            switch parsed_msg.action
            case 'been_here_fgt'
                @new_user_callback parsed_msg.id
                @initAndOffer user_id
            case 'join'
                @signaling_channel.send JSON.stringify {id:@id, action:'been_here_fgt'}
            case 'offer'
                if parsed_msg.data.dest == @id
                    @processOffer parsed_msg.id, parsed_msg.data.sdp
            case 'answer'
                if parsed_msg.data.dest == @id
                    @processAnswer parsed_msg.id, parsed_msg.data.sdp
    
    initAndOffer: (user_id) !->
        # Set up the peer connection
        temp_pc = new PeerConnection server, options
        @peer_connections[user_id] = {peer_connection:temp_pc}
        
        # Create a channel name
        channelname = getRandomString 20
        
        # Now wait until we've generated some ice candidates
        temp_pc.onicecandidate = (e) !->
            # When e.candidate is null, we're done generating candidates, so if
            # we grab the sdp offer now, it'll be nice and full of candidates
            # If you don't do this, chrome will be an asshole and just not put any
            #  candidates in your offer
            if e.candidate == null
                # Lets make an offer, encapsulate it in some json, and send it
                @signaling_channel.send JSON.stringify {id:@id, action:"offer", data:{dest:user_id, sdp:temp_pc.localDescription}}
        
        # Create a data channel for our peer connection
        @peer_connections[user_id].channel = temp_pc.createDataChannel(channelname, {});
        
        @peer_connections[user_id].channel.onmessage = (e) -> processMessage e
        
        @peer_connections[user_id].channel.onclose = (e) ->
            delete @peer_connections[user_id]
            @user_close_callback user_id
        
        # This actually creates the offer
        temp_pc.createOffer ((offer) !-> (temp_pc.setLocalDescription offer)), errorHandler
    
    processOffer: (user_id, sdp) !->
        # We got an offer, so create a new channel to deal with this new connection
        tempconnection = new PeerConnection server, options
        
        # Add the connection to our list
        @peer_connections[user_id] = {peer_connection:tempconnection}
        
        # We can't just create a data channel if we didn't make an offer, so we have to wait
        # for it to be created
        tempconnection.ondatachannel = (e) !->
            peerconnections[user_id].channel.onmessage = (e) -> processMessage e
        
            @peer_connections[user_id].channel.onclose = (e) ->
                delete @peer_connections[user_id]
                @user_close_callback user_id
            
            @peer_connections[user_id].channel = e.channel;

        # Now set our remote description to that offer sdp
        tempconnection.setRemoteDescription (new SessionDescription sdp),
                (!->
                    # Also create an answer, we're not some sort of deaf-mute
                    tempconnection.createAnswer ((answer) !->
                        # Our local description is just the answer
                        tempconnection.setLocalDescription (new SessionDescription answer),
                            (!->
                                # Create dat sexy json encapsulation and send it
                                @signaling_channel.send JSON.stringify {id:@id, action:"answer", data:{dest:user_id, sdp:answer}}
                            )
                            , errorHandler
                    )
                    , errorHandler
                )
                , errorHandler
    
    processAnswer: (user_id, sdp) !->
        # Find the peerconnection we sent the offer for
        tempconnection = @peer_connections[user_id].peerconnection
        
        # Set that connection's remote description to our offer, shit should connect automatically after this is done
        tempconnection.setRemoteDescription new SessionDescription sdp

    processMessage: (msg) !->
        parsed_msg = JSON.parse msg
        @message_callback parsed_msg

    send: (user_id, msg) !->
        @peer_connections[user_id].channel.send msg

    sendAll: (msg) !->
        for user in @peer_connections
            @peer_connections[user].send msg
