<%@ page import="entity.*" %>
<%@ page import="static tool.Query.getAllRooms" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="static tool.Query.searchEmptyRooms" %>
<%@ page import="tool.Query" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%--<%--%>
<%--Map<String, String[]> map =request.getParameterMap() ;--%>
<%--int mop = Integer.parseInt(map.get("mop")[0]) ; //control to view by mop number--%>

<%--%>--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <meta charset="UTF-8">
    <title>Lab Equipment Reservation System</title>
    <link rel="stylesheet" type="text/css" href="/semantic/dist/semantic.min.css">
    <script src="/semantic/dist/jquery.min.js"></script>
    <script src="/semantic/dist/semantic.js"></script>
    <script >

        function sub() {

            alert("Successfully Submitted! Returning to Lab Member List!")
            window.location.href="/systemManagement/showMembers.jsp"
        }

        function edit(waiterid) {
            window.location.href="/systemManagement/waiterUpdate.jsp?mop=4&waiterID="+waiterid;
        }

        function del(waiterid) {
            var f=confirm("Are you sure to remove this member？");
            if(f){

                window.location.href="/systemManagement/showMembers.jsp?mop=7&waiterID="+waiterid;
            }else{
                alert("you have cancelled the deletion");
            }

        }

    </script>

</head>
<%@include file="/systemAdmin.jsp"%>
<body>

<%ArrayList<Waiter> waiters = Query.getAllWaiters();%>
<div class="pusher">
    <div class="ui container">

        <h2 class="ui header">Edit Lab Members</h2>
        <table class="ui selectable celled table">
            <thead>
            <tr class="center aligned"><th name="waiterID">member ID</th>
                <th name="waiterName">Name</th>
                <th name="waiterBirthday">Birthday</th>
                <th name="waiterIDCard">CampusID</th>
                <th name="waiterPassword">Password</th>
                <th name="waiterJoinDate">Join Date</th>
                <th name="waiterPhoneNumber">Phone Number</th>
                <th name="remarks">Notes</th>
                <th></th>
                <th></th>
            </tr></thead>
            <tbody>
            <%for (int i=0;i<waiters.size();i++) {%>
            <tr class="center aligned">
                <td>
                    <%=(waiters.get(i).getWaiterID())%>
                </td>
                <td>
                    <%out.print(waiters.get(i).getWaiterName());%>
                </td>
                <td>
                    <% out.print(waiters.get(i).getWaiterBirthday().toString());%>
                </td>
                <td>
                    <%out.print(waiters.get(i).getWaiterIDCard());%>
                </td>
                <td>
                    <%out.print(waiters.get(i).getWaiterPassword());%>
                </td>
                <td>
                    <%out.print(waiters.get(i).getWaiterJoinDate().toString());%>
                </td>
                <td>
                    <%out.print(waiters.get(i).getWaiterPhoneNumber());%>
                </td>
                <td>
                    <%out.print(waiters.get(i).getRemarks());%>
                </td>

                <td>
                    <div class="ui button" tabindex="0"  onclick="edit('<%=(waiters.get(i).getWaiterID())%>')">Edit</div>
                </td>
                <td>
                    <div class="ui button" tabindex="0" onclick="del('<%=(waiters.get(i).getWaiterID())%>')">Delete</div>
                </td>
            </tr>
            <%}%>

            </tbody>
            <tfoot>
            </tfoot>
        </table>
    </div>
</div>

</body>
</html>
