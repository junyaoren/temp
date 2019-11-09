<%@ page import="entity.*" %>
<%@ page import="static tool.Query.getAllRooms" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="static tool.Query.searchFullRooms" %>
<%@ page import="static tool.Query.*" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="javax.print.DocFlavor" %>
<%@ page import="display.OrderView" %>
<%@ page import="tool.Query" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String rs1[] = {"Available","Reserved/In-use","All"};


    Map<String, String[]> map =request.getParameterMap();


    String size1=""  ;
    if( map.get("size1")!=null ){
        size1 = map.get("size1")[0] ;
    }

    String search ="" ;
    if(map.get("search")!=null){
        search =map.get("search")[0]  ;
    }
    ArrayList<Room> allRoomsInfo = getAllRoomsInfo(size1,search);
    HashMap<String, RoomTypeAndPrice> roomTypeMap = getRoomTypeMap();

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
    <script>
        function fun() {
            var obj = document.getElementsByName("size1");//选择所有name="id"的对象，返回数组
            var v='';//如果这样定义var v;变量v中会默认被赋个null值
            for(var i=0;i<obj.length;i++){
                if(obj[i].checked) {//取到对象数组后，我们来循环检测它是不是被选中
                    v+=('size1='+obj[i].value);
                }  //如果选中，将value添加到变量v中
            }
            window.location.href='/roomManagement/roomDisplay.jsp?'+v
        }

        function fun1( equipType,equipID) {
            window.location.href='/equipReserve.jsp?op=2&equipType='+equipType+'&equipmentID='+equipID

        }
        function func2() {
            var equipID = document.getElementById('equipID').value
            window.location.href='/roomManagement/roomDisplay.jsp?search='+equipID
        }
    </script>


</head>
<%@include file="/labMember.jsp"%>
<body>
<div class="pusher">
    <div class="ui container">
        <h2 class="ui header">View All Equipments</h2>
        <div class="ui column grid">
            <div class="four wide column">
                <div class="ui vertical  menu">
                    <div class="item">
                        <a class="active title">
                            <i class="dropdown icon"></i>
                            Status
                        </a>
                        <div class="active content">
                            <div class="ui form">
                                <div class="grouped fields">
                                    <%for (String s : rs1){%>
                                    <div class="field">
                                        <div class="ui radio checkbox">
                                            <input type="radio" name="size1" value=<%=s%>  <%=s.equals(size1)?"checked":""%> onclick="fun()">
                                            <label><%=s%></label>
                                        </div>
                                    </div>
                                    <%}%>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="eleven wide  column" >
                <div class="ui search ">
                    <div class="ui icon input">
                        <input class="prompt" type="text" id="equipID" <% if(!search.equals("")){ %>
                               value=<%=search%>
                                   <% }%> placeholder="Search Equipment...">

                    </div>
                    <div class="ui button" onclick="func2()"> <i class="search icon"></i>Search with equipmentID</div>
                </div>

                <br>
                <div class="ui three cards" >

                    <% for (Room roominfo :allRoomsInfo){ %>
                    <div class="card" >
                        <div class=" fluid image" >
                            <a class="ui big blue right corner label" >
                                <%
                                    String status = "";
                                    if (roominfo.getRoomStatus().equals("空")) {
                                      status = "Free";
                                    } else {
                                      status = "N/A";
                                    }
                                %>
                                <%=status%>
                            </a>
                            <img src=<%=roomTypeMap.get(roominfo.getRoomType()).getUrl()%> width="400" height="300"
                                 onclick="<%=roominfo.getRoomStatus().equals("非空")?"":"fun1('"+roominfo.getRoomType()+"','"+roominfo.getRoomNumber()+"')" %> ">
                        </div>
                        <div class="extra">
                            EquipmentID: <%=roominfo.getRoomNumber()%><br>
                            EquipmentType: <%=roominfo.getRoomType()%><br>
                            <% if(roominfo.getRoomStatus().equals("非空")){
                                OrderView view = Query.getFullOrderViews(roominfo.getRoomNumber());
                            %>
                            Using/Reserved-by: <%=view.getCustomer()%><br>
                            Available by: <%=view.getCheckOutTime()%><br>
                            <%} %>
                        </div>
                    </div>
                    <%}%>
                </div>
            </div>
        </div>
    </div>


</div>
</body>
</html>