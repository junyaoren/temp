<%@ page import="config.GCON" %>
<%@ page import="display.ExtensionOrderView" %>
<%@ page import="tool.Query" %><%--
  Created by IntelliJ IDEA.
  User: chironyf
  Date: 2017/12/26
  Time: 09:35
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Extended Reservations</title>
    <script>
        function nextPage(maxP) {

            var url = window.location.href;

            var urlHead = window.location.href.split("&")[0];

            var oldPageIndex = parseInt(url.split("&")[1].split("=")[1]);

            if (oldPageIndex < 0) {
                oldPageIndex = 0;
            }

            if (oldPageIndex >= maxP) {
                oldPageIndex = maxP - 1;
            }

            var newPageIndex = oldPageIndex + 1;

            window.location.href = urlHead + "&pageIndex=" + newPageIndex;

        }

        function prePage(maxP) {
            var url = window.location.href;

            var urlHead = window.location.href.split("&")[0];

            var oldPageIndex = parseInt(url.split("&")[1].split("=")[1]);

            if (oldPageIndex < 0) {
                oldPageIndex = 1;
            }

            if (oldPageIndex >= maxP) {
                oldPageIndex = maxP;
            }

            var newPageIndex = oldPageIndex - 1;

            window.location.href = urlHead + "&pageIndex=" + newPageIndex;
        }

        function jump(maxP) {

            var urlHead = window.location.href.split("&")[0];

            var newPageIndex = parseInt(document.getElementById("pageIndex").value);

            if (!isInteger(newPageIndex)) {
                alert('Wrong PageNumber, try again!');
                return;
            }

            if (newPageIndex < 0) {
                newPageIndex = 0;
            }

            if (newPageIndex >= maxP) {
                newPageIndex = maxP;
            }


            window.location.href = urlHead + "&pageIndex=" + newPageIndex;
        }

        function isInteger(obj) {
            return typeof obj === 'number' && obj%1 === 0
        }

    </script>
</head>
<%@include file="/labMember.jsp"%>
<body>
<%
    ArrayList<ExtensionOrderView> extensionOrderViews = Query.getAllTimeExtensionOrders();

    //如果订单非空
    if (extensionOrderViews.size() != 0) {

        int currentOrderSize = extensionOrderViews.size();
        //每页显示10条记录
        int pageNumber = 10;

        int maxPageNumber = (currentOrderSize - 1) / pageNumber;

        boolean pageIndexFlow = false;

        boolean pageIndexNegative = false;

        int currentPageNumber =  Integer.parseInt(request.getParameter("pageIndex").toString());

        if (currentPageNumber <= 0) {
            currentPageNumber = 0;

            pageIndexNegative = true;
        }

        if (currentPageNumber > maxPageNumber) {
            currentPageNumber = maxPageNumber;
            pageIndexFlow = true;
        }

        int startIndex = currentPageNumber * pageNumber;

        int endIndex = (startIndex + pageNumber - 1) > currentOrderSize - 1 ? currentOrderSize - 1 : (startIndex + pageNumber - 1);

        if (endIndex >= currentOrderSize - 1) {
            pageIndexFlow = true;
        }
%>
<table class="ui sortable celled table">
    <thead>
    <tr class="center aligned">
        <th class="sorted descending">Reservation Number</th>
        <th>User</th>
        <th>EquipmentID</th>
        <th>StartDate</th>
        <th>Original EndDate</th>
        <th>New EndDate</th>
        <%--<th>手机号码</th>--%>
        <%--<th>补交金额</th>--%>
    </tr></thead>

    <tbody>
    <%
        for (int i = startIndex; i <= endIndex; i++) {
    %>
    <tr class="center aligned">
        <td>
            <%
                out.print(extensionOrderViews.get(i).getOrderNumber());
            %>
        </td>
        <td>
            <%
                out.print(extensionOrderViews.get(i).getCustomer());
            %>
        </td>
        <td>
            <%
                out.print(extensionOrderViews.get(i).getRoomNumber());
            %>
        </td>
        <td>
            <%
                out.print(extensionOrderViews.get(i).getCheckInTime().toString());
            %>
        </td>
        <td>
            <%
                out.print(extensionOrderViews.get(i).getOldDate().toString());
            %>
        </td>
        <td>
            <%
                out.print(extensionOrderViews.get(i).getNewDate().toString());
            %>
        </td>
        <%--<td>--%>
            <%--<%--%>
                <%--out.print(extensionOrderViews.get(i).getCustomerPhoneNumber());--%>
            <%--%>--%>
        <%--</td>--%>
        <%--<td>--%>
            <%--<%--%>
                <%--out.print(extensionOrderViews.get(i).getAddedMoney());--%>
            <%--%>--%>
        <%--</td>--%>
    </tr>
    <%}
    %>

    </tbody>
    <tfoot>
    <tr>
        <th colspan="11">
            <div class="ui right floated pagination menu">
                <a class="icon item">
                    <h4>Page&nbsp;:&nbsp;<%=currentPageNumber%>/<%=maxPageNumber%></h4>
                </a>
                <a class="icon item">
                    <div class="ui mini icon input">
                        <input type="text" placeholder="go to..." id="pageIndex">
                        <i class="search icon"></i>
                    </div>
                    <a class="icon item" onclick="jump(<%=maxPageNumber%>)">
                        <i class="reply icon"></i>
                        <label>&nbsp;jump</label>
                    </a>
                </a>
                <%if (!pageIndexNegative) {%>
                <a class="icon item" onclick="prePage(<%=maxPageNumber%>)">
                    <i class="left chevron icon"></i>
                    <label>&nbsp;Prev</label>
                </a>
                <%} else {%>
                <a class="icon item">
                    <i class="smile icon"></i>
                    <label>First</label>
                </a>
                <%}%>
                <%if (!pageIndexFlow) {%>
                <a class="icon item" onclick="nextPage(<%=maxPageNumber%>)">
                    <label>Next&nbsp;</label>
                    <i class="right chevron icon"></i>
                </a>
                <%} else {%>
                <a class="icon item">
                    <label>End&nbsp;</label>
                    <i class="frown icon"></i>
                </a>
                <%}%>
            </div>
        </th>
    </tr>
    </tfoot>

</table>
<%} else {%>

<div class="ui middle aligned center aligned grid">
    <div class="column">
        <br>
        <br>
        <br>
        <br>
        <br>
        <h1 class="ui red header"><i class="folder open icon"></i>No Extended Reservations!!!</h1>
    </div>
</div>

<%}%>

</body>
</html>
