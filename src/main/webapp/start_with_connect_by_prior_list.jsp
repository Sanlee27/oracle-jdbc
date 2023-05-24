<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*"%>
<%@ page import = "java.util.*"%>            
<%    
	// DB
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dburl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbuser = "hr";
	String dbpw = "java1234";

	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser,dbpw);
	
	// ================계층쿼리================
	/*
		start with ~ ?? -- root 조건
		connect by prior ?? = ??; -- 다음행 조건 : 현재행 가지의 마지막행까지 반복(루프)
		
		- 그외 계층쿼리 확장 함수
		- LEVEL, CONNECT_BY_ROOT, CONNECT_BY_ISLEAF, SYS_CONNECT_BY_PATH(column, char)
	*/
	// ===========계층쿼리===============
	PreparedStatement stmt = null;
	ResultSet rs = null;
	String sql = "select level 레벨,employee_id 사원ID, lpad(' ', level-1)|| first_name 이름, manager_id 상급자ID, SYS_CONNECT_BY_path(first_name, '-') 직급계층 from employees start with manager_id is null connect by prior employee_id = manager_id"; 
	/*
		root 조건 : start with manager_id is null > manager_id가 null인거부터 시작
		다음행 조건 : 현재행 가지의 마지막행까지 반복(루프) > connect by prior employee_id = manager_id;
	*/
	stmt = conn.prepareStatement(sql);
	
	System.out.println(stmt + " : start_with_connect_by_prior_list stmt");
	
	rs = stmt.executeQuery();
	
	ArrayList<HashMap<String, Object>> list = new ArrayList<HashMap<String, Object>>();
	while(rs.next()){
		HashMap<String, Object> r = new HashMap<String, Object>();
		r.put("레벨", rs.getString("레벨"));
		r.put("사원ID", rs.getString("사원ID"));
		r.put("이름", rs.getString("이름"));
		r.put("상급자ID", rs.getString("상급자ID"));
		r.put("직급계층", rs.getString("직급계층"));
		list.add(r);
	}

%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<h3>계층쿼리</h3>
	<table border="1">
		<tr>
			<th>레벨</th>
			<th>사원ID</th>
			<th>이름</th>
			<th>상급자ID</th>
			<th>직급계층</th>
		</tr>
		<%
			for(HashMap<String,Object> r : list){
		%>
				<tr>
					<td><%=(String)(r.get("레벨"))%></td>
					<td><%=(String)(r.get("사원ID"))%></td>
					<td><%=(String)(r.get("이름"))%></td>
					<td><%=(String)(r.get("상급자ID"))%></td>
					<td><%=(String)(r.get("직급계층"))%></td>
				</tr>
		<%
			}
		 %>
	</table>
</body>
</html>