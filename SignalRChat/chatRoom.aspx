﻿<%@ Page Title="" Language="C#" MasterPageFile="~/chatApp.Master" AutoEventWireup="true" CodeBehind="chatRoom.aspx.cs" Inherits="SignalRChat.chatRoom" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style type="text/css">
        .chat-container {
            background-color: #99CCFF;
            border: thick solid #808080;
            padding: 20px;
            width:100%;
        }

        .body-content{
            padding:50px;
        }

        .discussion-content{
            height:250px;
            overflow-y:scroll;
        }
    </style>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <script src="Scripts/app.js"></script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="chat-container">
        <div class="mt-3 mb-3">
            <div class="bg-dark text-light text-center p-2 mb-3 rounded">
                <h3 class="mb-0">Chat Records</h3> 
            </div>
             <asp:Literal ID="ltrDiscussion" runat="server"></asp:Literal>
        </div>
        
        <div class="form-group">
            <label for="">Name: </label>
            <asp:TextBox ID="txtName" runat="server" CssClass="form-control"></asp:TextBox>
        </div>

        <div class="form-group">
            <label for="">Message: </label>
            <textarea id="message" class="form-control" rows="7" onkeydown="enterSendMessage()"></textarea>
        </div>

        <div class="text-danger" style="display:none;" id="error-prompt">
            Name and Message are required!
        </div>

        <div class="form-group mt-3">
            <input type="button" id="sendmessage" value="Send" class="btn btn-dark"/>
        </div>

    </div>
    <!--Script references. -->
    <!--Reference the jQuery library. -->
    <script src="Scripts/jquery-3.4.1.min.js"></script>
    <!--Reference the SignalR library. -->
    <script src="Scripts/jquery.signalR-2.2.2.min.js"></script>
    <!--Reference the autogenerated SignalR hub script. -->
    <script src="signalr/hubs"></script>
    <!--Add script to update the page and send messages.--> 
    <script type="text/javascript">

        // Declare a proxy to reference the hub. 
        var chat = $.connection.chatHub;

        // Create a function that the hub can call to broadcast messages.
        chat.client.broadcastMessage = function (name, message, sent_time) {

            var name_input = document.getElementById("ContentPlaceHolder1_txtName").value;

            // Html encode display name and message. 
            var encodedName = $('<div />').text(name).html();
            var encodedMsg = $('<div />').text(message).html();

            if (name_input === name) {
                // Add the message to the page. 
                $('#discussion').append('<li><strong>(You) ' + encodedName + " [" + sent_time + "]"
                    + '</strong>:&nbsp;&nbsp;' + encodedMsg + '</li>');
            }
            else {
                // Add the message to the page. 
                $('#discussion').append('<li><strong>' + encodedName + " [" + sent_time + "]"
                    + '</strong>:&nbsp;&nbsp;' + encodedMsg + '</li>');
            }

            //Scroll to bottom when the new image appear
            scrollToBottom();
        };


        // Start the connection.
        $.connection.hub.start().done(function () {
            $('#sendmessage').click(function () {
                sendMessage();
            });

        });

        function sendMessage() {
            var name = document.getElementById("ContentPlaceHolder1_txtName").value;
            var message = document.getElementById("message").value;
            var error_prompt = document.getElementById("error-prompt");

            if (name.trim().length !== 0 && message.trim().length !== 0) {

                //Remove error-prompt
                error_prompt.style.display = "none";

                var post_data = {
                    chat_content: message,
                    sender_name: name
                };

                // Set Cookies
                setNameCookie("sender-name", name, 7);

                $.ajax({
                    type: "POST",
                    url: "/chatRoom.aspx/submit",
                    data: JSON.stringify(post_data),
                    contentType: 'application/json; charset=utf-8',
                    success: function (result) {
                        console.log("We returned: " + JSON.stringify(result));
                        //Clear the message box
                        $('#message').val('');

                        // Call the Send method on the hub. 
                        chat.server.send(name, message, result.d);

                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        console.log("Request: " + JSON.stringify(XMLHttpRequest) + "\n\nStatus: " + textStatus + "\n\nError: " + errorThrown);
                    }
                });

            }
            else {
                //Display error-prompt
                error_prompt.style.display = "";
            }
        }

        function enterSendMessage() {
            if (event.keyCode === 13) {
                sendMessage();
            }
        }

        function scrollToBottom() {
            var messages = document.getElementById("discussion");
            messages.scrollTop = messages.scrollHeight;
        }

        //Call scrollToBottom by default when the page is refresh
        scrollToBottom();

    </script>
</asp:Content>
