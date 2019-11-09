<%--
  Created by IntelliJ IDEA.
  User: chironyf
  Date: 2017/12/26
  Time: 08:41
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="entity.*" %>
<%@ page import="static tool.Query.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="config.GCON" %>
<%@ page import="java.util.Map" %>
<%@ page import="tool.Query" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Map<String, String[]> map = request.getParameterMap() ;
    int op = Integer.parseInt(map.get("op")[0]) ; //通过op选项来控制页面显示的内容
%>

<html>
<head>
    <meta charset="UTF-8">
    <title>Add New Equipment</title>
    <script>

        function returnMainPage() {
            window.location.href="/roomManagement/equipAdd.jsp?op=2";
        }

        function submitNewEquipInfo() {
            // print("hello");
            var EquipmentID = document.getElementById("EquipmentID").value;
            var EquipmentType = document.getElementById("EquipmentType").value;
            console.log(EquipmentType);
            var remarks = document.getElementById("remarks").value;
            if( /^[0-9]{6}$/.test(EquipmentID)){
                var url = "&EquipmentID=" + EquipmentID + "&EquipmentType=" + EquipmentType + "&remarks=" + remarks;
                console.log(url);
                window.location.href = "/roomManagement/equipAdd.jsp?op=3" + url;
            }

            return false ;
        }

        function ensureButtonClicked() {

            // var roomnumber = document.getElementById('roomNumber')
            // var roomtype= document.getElementById('roomType')

            var urlNew = window.location.href.split("&")[1] + "&" + window.location.href.split("&")[2]
                + "&" + window.location.href.split("&")[3];

            window.location.href = "/roomManagement/equipAdd.jsp?op=4&" + urlNew;


        }

    </script>

</head>
<%@include file="/labMember.jsp"%>
<body>

<div class="pusher">

    <div class="ui container">
        <h2 class="ui header">Add New Equipment</h2>
        <div class="ui column grid">
            <div class="four wide column">
                <div class="ui vertical steps">

                    <div class="<%=(op == 2) ? "active step ":"completed step"%>" >
                        <i class="add circle icon"></i>
                        <div class="content">
                            <div class="title">Equipment Info</div>
                        </div>
                    </div>

                    <div class="<%=(op == 3) ? "active step ":(op== 2)?"step":"completed step"%>">
                        <i class="check circle icon"></i>
                        <div class="content">
                            <div class="title">Confirm</div>
                        </div>
                    </div>

                </div>

            </div>

            <div class="eleven wide  column" >

                <%// add info about new equip
                    if (op == 2) {
                %>
                <form class="ui form" onsubmit="return submitNewEquipInfo(this)">
                    <h2 class="ui dividing header">Fill the equipment information</h2>
                    <div class="two fields">
                        <div class="field">
                            <label>EquipmentID</label>
                            <input type="text" id="EquipmentID" name="EquipmentID" placeholder="EquipmentID" value= <%= "" + (int) (Math.random() * (999999 - 100000) + 100000) %>>
                        </div>
                        <div class="field">
                            <label>Equipment Type</label>
                            <% ArrayList<RoomTypeAndPrice> rooms = getAllRooms();%>
                            <select class="ui fluid dropdown" id="EquipmentType">
                                <%for(RoomTypeAndPrice room :rooms){%>
                                <option value=<%=String.join("%20", room.getRoomType().split(" "))%>><%=room.getRoomType()%></option>
                                <%}%>
                            </select>
                        </div>
                    </div>
                    <div class="field">
                        <label>Notes</label>
                        <input type="text" id="remarks" placeholder="Some description about the equipment...">
                    </div>
                    <div class="ui submit button">Submit</div>
                </form>

                <%} else if (op == 3) {
                %>

                <h2 class="ui dividing header">Confirm Equipment Information</h2>
                <form class="ui form">
                    <table class="ui table">
                        <thead>
                        <tr><th class="six wide">Equipment ID</th>
                            <th class="six wide">Equipment Type</th>
                            <th class="six wide">Notes</th>
                        </tr></thead>
                        <tbody>
                        <tr>
                            <td><%=request.getParameter("EquipmentID")%></td>
                            <td><%=request.getParameter("EquipmentType")%></td>
                            <td><%=request.getParameter("remarks")%></td>
                        </tr>
                        </tbody>
                    </table>

                    <div class="ui button" onclick="ensureButtonClicked()">Confirm</div>
                </form>

                <%} else if (op == 4) {
                    Room newRoom = new Room();
                    newRoom.setRoomStatus("空");
                    newRoom.setRoomNumber(request.getParameter("EquipmentID"));
                    newRoom.setRoomType(request.getParameter("EquipmentType"));
                    newRoom.setRemarks(request.getParameter("remarks"));
                    Query.insertRoom(newRoom);
                %>
                <h4 class="ui dividing header">Added Successfully</h4>
                <div class="ui right button" onclick="returnMainPage()">Back</div>
                <%}%>
            </div>
        </div>
    </div>

    <%--<h1>欢迎宾馆管理员登录！</h1>--%>

</div>

</body>
</html>
<script>
    $(document).ready(function () {
        $('.ui.form').form({
                // if( /^[0-9]{6}$/.test(room) && /^[1-9][0-9]?$/.test(time) && /^[0-9]{18}$/.test(idcard)
                //         && /^1[3|4|5|8][0-9]\d{4,8}$/.test(phonenumber) ){
            EquipmentID: {
                    identifier: 'EquipmentID',
                    rules: [
                        {
                            type: 'regExp[/^[0-9]{6}$/]',
                            prompt: 'Invalid EquipmentID'
                        }
                    ]
                }

            }, {

                inline : true,
                on     : 'submit'

            }
        )

        ;
    });
</script>