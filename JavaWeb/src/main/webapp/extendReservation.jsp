<%@ page import="entity.*" %>
<%@ page import="static tool.Query.getAllRooms" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="static tool.Query.searchFullRooms" %>
<%@ page import="static tool.Query.*" %>
<%@ page import="java.sql.Date" %>
<%@ page import="java.util.Calendar" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Map<String, String[]> map =request.getParameterMap() ;
    int op = Integer.parseInt(map.get("op")[0]) ; //通过op选项来控制页面显示的内容
    TimeExtension renew=null ;
    if(op==2){

        //查询原订单号
        Order order = getOrder(map.get("equipmentID")[0]);
        String orderid =order.getOrderNumber() ;
        //查询员订单截止时间
        Date olddate = order.getCheckOutTime();
        Date newdate = order.getCheckOutTime();
        Calendar calendar =Calendar.getInstance();
        calendar.setTime(newdate);
        System.out.println(Integer.parseInt(map.get("time")[0]) );
        calendar.add(5, Integer.parseInt(map.get("time")[0]));
        //算出新截止时间
        newdate = new Date(calendar.getTime().getTime()) ;
        //算出 价格 =单价*折扣*天数 ;
        double discount = searchDiscount(order.getCustomerIDCard());

        int price = 1  ;
        renew=new TimeExtension(getRenewNum()+1,orderid,olddate,newdate,(int)(discount*Integer.parseInt(map.get("time")[0])
                *getRoomPrice(order.getRoomNumber()))) ;
        request.getSession().setAttribute("renew",renew);

    }

%>

<html>
<head>
    <meta charset="UTF-8">
    <title>Lab Equipment Reservation System</title>
    <link rel="stylesheet" type="text/css" href="/semantic/dist/semantic.min.css">
    <script src="/semantic/dist/jquery.min.js"></script>
    <script src="/semantic/dist/semantic.js"></script>
    <link rel="stylesheet" type="text/css" href="/semantic/dist/components/reset.css">
    <link rel="stylesheet" type="text/css" href="/semantic/dist/components/site.css">

    <link rel="stylesheet" type="text/css" href="/semantic/dist/components/container.css">
    <link rel="stylesheet" type="text/css" href="/semantic/dist/components/divider.css">
    <link rel="stylesheet" type="text/css" href="/semantic/dist/components/grid.css">

    <link rel="stylesheet" type="text/css" href="/semantic/dist/components/header.css">
    <link rel="stylesheet" type="text/css" href="/semantic/dist/components/segment.css">
    <link rel="stylesheet" type="text/css" href="/semantic/dist/components/table.css">
    <link rel="stylesheet" type="text/css" href="/semantic/dist/components/icon.css">
    <link rel="stylesheet" type="text/css" href="/semantic/dist/components/menu.css">
    <link rel="stylesheet" type="text/css" href="/semantic/dist/components/message.css">

    <style type="text/css">
        h2 {
            margin: 1em 0em;
        }
        .ui.container {
            padding-top: 5em;
            padding-bottom: 5em;
        }
    </style>

    <script >

        function fun1() {

            alert("Successfully Extended! Returning to Your Homepage...")
            window.location.href="/ServiceManage?op=4";
        }

        function func2() {

            var equipmentID = document.getElementById("equipmentID").value
            var time = document.getElementById("time").value
            var pat1 = /^[0-9]{6}$/ ;
            var pat2 =/^[1-9][0-9]?$/ ;

            if(pat1.test(equipmentID) && pat2.test(time)){
                window.location.href="/extendReservation.jsp?op=2&equipmentID="+equipmentID+"&time="+time
            }
            return false
        }

    </script>
</head>

<%@include file="/labMember.jsp"%>


<body>

<div class="pusher">


    <div class="ui container">
        <h2 class="ui header">Extend a reservation</h2>
        <div class="ui column grid">
            <div class="four wide column">
                <div class="ui vertical steps">

                    <div class="<%=(op<=1)?"active step ":"completed step"%>" >
                        <i class="building icon"></i>
                        <div class="content">
                            <div class="title">Select EquipID</div>
                            <%--<div class="description">Choose your shipping options</div>--%>
                        </div>
                    </div>

                    <div class="<%=(op==2)?"active step ":(op==1)?"step":"completed step"%>">
                        <i class="info icon"></i>
                        <div class="content">
                            <div class="title">Confirmation</div>
                            <%--<div class="description">Enter billing information</div>--%>
                        </div>
                    </div>

                </div>
            </div>
            <div class="eleven wide  column" >

                <%  if(op==1){ %>
                <form class="ui form" onsubmit="return func2(this)">
                    <h4 class="ui dividing header">Select an equipmentID to extend your reservation</h4>
                    <div class="four wide column">
                        <label>Room</label>


                        <div class="five wide field">


                            <select class="ui fluid search dropdown" id="equipmentID" name="equipmentID">

                                <%
                                    ArrayList<String> list = searchFullRooms();
                                    if(list.size()==0){
                                %>
                                <option value="No reservation to extend">N/A</option>
                                <%
                                    }
                                    for(String str : list){
                                %>
                                <option value=<%=str%>> <%=str%> </option>
                                <% } %>
                            </select>
                            <%--<input type="text" name="roomid" placeholder="房间号">--%>
                        </div>
                    </div>
                    <h4 class="ui dividing header">Extension Time</h4>
                    <div class="eight wide field">
                        <label>Time</label>
                        <div class=" fields">
                            <div class="eight wide field">

                                <input type="text" maxlength="8"  placeholder="time" id="time" name="time" value="2">
                            </div>
                        </div>

                    </div>
                    <br/>
                    <div class="ui right submit floated button" tabindex="0" >Submit Extension</div>
                </form>
                <% } else if(op==2){ %>


                <h4 class="ui dividing header">Confirmation</h4>
                <table class="ui table">
                    <thead>
                    <tr><th class="six wide">Name</th>
                        <th class="ten wide">Info</th>
                    </tr></thead>
                    <tbody>
                    <tr>
                        <td>Extension ID</td>
                        <td><%=renew.getOperatingID() %></td>
                    </tr>
                    <tr>
                        <td>Original Reservation Number</td>
                        <td><%=renew.getOrderNumber() %></td>
                    </tr>
                    <tr>
                        <td>Original Expiration Date</td>
                        <td><%=renew.getOldExpiryDate() %></td>
                    </tr>
                    <%--<tr>--%>
                        <%--<td>支付金额</td>--%>
                        <%--<td><%=renew.getAddedMoney() %></td>--%>
                    <%--</tr>--%>
                    <tr>
                        <td>New Expiration Date</td>
                        <td><%=renew.getNewExpiryDate() %></td>
                    </tr>
                    </tbody>
                </table>


                <h4 class="ui dividing header">Submit</h4>
                <div class="ui right floated labeled button" tabindex="0">
                    <a class="ui basic right pointing label">
                        <%-- 去数据库查询价格 * 天数 *相应的折扣 --%>
                        <%--¥<%=renew.getAddedMoney() %>--%>
                    </a>
                    <div class="ui right button" onclick="fun1()">
                        <i class="shopping icon"></i> Submit
                    </div>
                </div>
                <%}%>

            </div>
            <%--<h1>欢迎续费</h1>--%>
            <%--  续费房间号 下拉列表   续费时长 缴纳金额  续费要改相应的order表格的退房日期 --%>

</body>
</html>
<script>
    $(document).ready(function () {
        $('.ui.form').form({
                // if( /^[0-9]{6}$/.test(room) && /^[1-9][0-9]?$/.test(time) && /^[0-9]{18}$/.test(idcard)
                //         && /^1[3|4|5|8][0-9]\d{4,8}$/.test(phonenumber) ){
                time: {
                    identifier: 'time',
                    rules: [
                        {
                            type: 'regExp[/^[1-9][0-9]?$/]',
                            prompt: 'Invalid Time'
                        }
                    ]
                }
                ,equipmentID: {
                    identifier: 'equipmentID',
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
