<%@ page import="config.GCON" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.DriverManager" %>
<%@ page import="tool.DataBase" %>
<%@ page import="static tool.DataBase.MAP" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    if (session.getAttribute("systemadmin") == null) {
        response.sendRedirect("./index.jsp");
    }

//    String sn = request.getSession().getAttribute("systemadmin").toString();
    if(GCON.status==0){ //修改权限
        DataBase.setConnection(MAP.get(GCON.SYSTEMUSERNAME));
        GCON.status=1 ;
    }
%>

<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="pragma" content="no-cache">
    <meta http-equiv="cache-control" content="no-cache">
    <meta http-equiv="expires" content="0">
    <title>Lab Equipment Reservation System</title>
    <link rel="stylesheet" type="text/css" href="../semantic/dist/semantic.min.css">
    <script src="../semantic/dist/jquery.min.js"></script>
    <script src="../semantic/dist/semantic.js"></script>
    <link rel="stylesheet" type="text/css" href="../semantic/dist/components/reset.css">
    <link rel="stylesheet" type="text/css" href="../semantic/dist/components/site.css">

    <link rel="stylesheet" type="text/css" href="../semantic/dist/components/container.css">
    <link rel="stylesheet" type="text/css" href="../semantic/dist/components/divider.css">
    <link rel="stylesheet" type="text/css" href="../semantic/dist/components/grid.css">

    <link rel="stylesheet" type="text/css" href="../semantic/dist/components/header.css">
    <link rel="stylesheet" type="text/css" href="../semantic/dist/components/segment.css">
    <link rel="stylesheet" type="text/css" href="../semantic/dist/components/table.css">
    <link rel="stylesheet" type="text/css" href="../semantic/dist/components/icon.css">
    <link rel="stylesheet" type="text/css" href="../semantic/dist/components/menu.css">
    <link rel="stylesheet" type="text/css" href="../semantic/dist/components/message.css">

    <style type="text/css">
        h2 {
            margin: 1em 0em;
        }
        .ui.container {
            padding-top: 5em;
            padding-bottom: 5em;
        }
    </style>
    <script>
        var i=0;
        function myDate(){
            var now=new Date();
            var year=now.getFullYear();
            var month=now.getMonth()+1;
            var day=now.getDate();
            var hours=now.getHours();
            var minutes=now.getMinutes();
            var seconds=now.getSeconds();
            document.getElementById("div").innerHTML=year+"-"+fix(month, 2)+"-"+fix(day, 2)+"-"+fix(hours, 2)+" : "+fix(minutes, 2)+" : "+fix(seconds, 2);
        }

        function fix(num, length) {
            return ('' + num).length < length ? ((new Array(length + 1)).join('0') + num).slice(-length) : '' + num;
        }
        setInterval(myDate,1000);
    </script>
</head>

<body>
<div class="pusher">
    <div class="ui  inverted menu">
        <a class="item"href="/AdministrationManage?mop=7">
            <i class="sitemap icon"></i>
            Tree Map of Lab Members
        </a>
        <div class="ui simple dropdown item">
            <i class="users icon"></i>Manage Members
            <i class="dropdown icon"></i>
            <div class="menu">
                <a class="item" href="/AdministrationManage?mop=4"><i class="add user icon"></i>Add New Lab Member</a>
                <a class="item" href="/AdministrationManage?mop=5"><i class="edit icon"></i>Edit Lab Member</a>
            </div>
        </div>

        <a class="item" href="/AdministrationManage?mop=10">
            <i class="bar chart icon"></i>Reservation Statistics
        </a>

        <div class="right menu">
            <div class="ui simple dropdown item">
                <div id="div"></div>
            </div>
        </div>


        <div class="right menu">
            <div class="ui simple dropdown item">
                <i class="user icon"></i>
                <%="SystemAdmin: " + session.getAttribute("systemadmin")%>

                <i class="dropdown icon"></i>
                <div class="menu">
                    <a class="item" href="/ServiceManage?op=10"><i class="sign out icon"></i>Logout</a>
                </div>
            </div>
        </div>
    </div>
</div>

</body>
</html>
