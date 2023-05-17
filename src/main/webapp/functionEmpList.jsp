<%@page import="oracle.net.aso.r"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*"%>
<%@ page import = "java.util.*"%>   
<%
	//===================페이징연습========================
	int currentPage = 1;
	if(request.getParameter("currentPage") != null){
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dburl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbuser = "hr";
	String dbpw = "java1234";
	
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser,dbpw);
	
	System.out.println(conn);
	
	// =========================================== 
	int totalRow = 0;
	String totalRowSql = "SELECT COUNT(*) from employees";
	PreparedStatement totalRowStmt = conn.prepareStatement(totalRowSql);
	ResultSet totalRowRs = totalRowStmt.executeQuery();
	if(totalRowRs.next()){
		totalRow = totalRowRs.getInt(1); // totalRowRs.getInt(count(*));
	}
	
	int rowPerPage = 10;
	int beginRow = (currentPage - 1) * rowPerPage + 1;
	int endRow = beginRow + (rowPerPage - 1);
	if(endRow > totalRow){
		endRow = totalRow;
	}
	
	/* 
		select 번호, 이름, 이름첫글자, 연봉, 급여, 입사날짜, 입사년도
		from
    		(select rownum rnum,last_name 이름, substr(last_name, 1, 1) 이름첫글자, salary 연봉, round(salary/12,2) 급여, hire_date 입사날짜, extract(year from hire_date) 입사년도 from employees);
		where 번호 between 1 and 10;
	*/
	
	String sql = "select 번호, 이름, 이름첫글자, 연봉, 급여, 입사날짜, 입사년도 from (select rownum 번호, last_name 이름, substr(last_name, 1, 1) 이름첫글자, salary 연봉, round(salary/12, 2) 급여, hire_date 입사날짜, extract(year from hire_date) 입사년도 from employees) where 번호 between ? and ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setInt(1, beginRow);
	stmt.setInt(2, endRow);
	
	ResultSet rs = stmt.executeQuery();
	ArrayList<HashMap<String, Object>> list = new ArrayList<>();
	while(rs.next()){
		HashMap<String, Object> l = new HashMap<String, Object>(); 
		l.put("번호", rs.getInt("번호"));
		l.put("이름", rs.getString("이름"));
		l.put("이름첫글자", rs.getString("이름첫글자"));
		l.put("연봉", rs.getInt("연봉"));
		l.put("급여", rs.getDouble("급여"));
		l.put("입사날짜", rs.getString("입사날짜"));
		l.put("입사년도", rs.getInt("입사년도"));
		list.add(l);
	}
	
	System.out.println(list.size() + " : functionEmpList list.size()");
	
%>    
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<table border = "1">
		<tr>
			<th>번호</th>
			<th>이름</th>
			<th>이름첫글자</th>
			<th>연봉</th>
			<th>급여</th>
			<th>입사날짜</th>
			<th>입사년도</th>
		</tr>
		<%
			for(HashMap<String, Object> l : list){
		%>
				<tr>
					<td><%=(Integer)(l.get("번호"))%></td>
					<td><%=(String)(l.get("이름"))%></td>
					<td><%=(String)(l.get("이름첫글자"))%></td>
					<td><%=(Integer)(l.get("연봉"))%></td>
					<td><%=(Double)(l.get("급여"))%></td>
					<td><%=(String)(l.get("입사날짜"))%></td>
					<td><%=(Integer)(l.get("입사년도"))%></td>
				</tr>
		<%
			}
		%>
	</table>
	
		<%
			// ========== 페이지 네비게이션 페이징
			/*
				cp	minPage	~ maxPage
				1	   1		10
				2	   1		10
				10	   1		10	 
				
				11	   11		20
				12	   11		20
				20	   11		20
				
				(cp-1) / pagePerPage * pagePerPage + 1 >> minPage
				minPage + (pagePerPage-1) >> maxPage
				maxPage > lastPage        >> maxPage = lastPage
			*/
			int pagePerPage = 10;
			int lastPage = totalRow / rowPerPage;
			if(totalRow % rowPerPage != 0){
				lastPage = lastPage + 1;
			}
			
			int minPage = ((currentPage - 1) / pagePerPage * pagePerPage) + 1 ;
			int maxPage = minPage + (pagePerPage - 1);
			if(maxPage > lastPage){
				maxPage = lastPage;
			}
			
			if(minPage > 1){
		%>
			<!-- ==========페이지버튼========  -->
				<a href="./functionEmpList.jsp?currentPage=<%=minPage-rowPerPage%>">이전</a>&nbsp;
		<%	
			}
			
			for(int i = minPage; i<=maxPage; i++){
				if(i == currentPage){
		%>
					<span><%=i%></span>
		<%	
				} else {
		%>
					<a href="./functionEmpList.jsp?currentPage=<%=i%>"><%=i%></a>&nbsp;
		<%			
				}
			}
			
			if(maxPage != lastPage){
		%>
				<a href="./functionEmpList.jsp?currentPage=<%=minPage+rowPerPage%>">다음</a>&nbsp;
		<%
			}
		%>	
</body>
</html>