var chatSocket = new WebSocket('ws://localhost:8000/ws/playlist/1/');

chatSocket.onmessage = function(e) {
        var data = JSON.parse(e.data);
        var message = data['message'];
        console.log(message + '\n');
    };

//var message = 'zalupa'

//chatSocket.send(JSON.stringify({'message': message}));



// <script>
//
// var loc = window.location;
// var wsStart = 'ws://';
// if (loc.protocol == 'https:') {
//     wsStart = 'wss://'
// }
// var endpoint = wsStart + loc.host + loc.pathname;
//
// var socket = new WebSocket(endpoint);
//
// socket.onmessage = function(e){
//     console.log("message", e);
// };
// socket.onopen = function(e){
//     console.log("open", e);
// };
// socket.onerror = function(e){
//     console.log("error", e)
// };
// socket.onclose = function(e){
//     console.log("close", e)
// };
// </script>