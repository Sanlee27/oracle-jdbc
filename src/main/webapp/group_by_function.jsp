<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*"%>
<%@ page import = "java.util.*"%>    
<%
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dburl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbuser = "hr";
	String dbpw = "java1234";

	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser,dbpw);
	
	System.out.println(conn);
	
	// ===========================================
		/*
	   	group by 절에서 사용가능한 확장 함수
		    1) grouping sets()
		    2) rollup()
		    3) cube()
	   */
	   
	// grouping sets
	// grouping sets() 안에 있는 속성을 각각 group by 해서 union all 한것
	PreparedStatement setsStmt = null;
	ResultSet setsRs = null;
	String setsSql = "select department_id, job_id, count(*) from employees group by grouping sets(department_id, job_id)";
	setsStmt = conn.prepareStatement(setsSql);
	
	System.out.println(setsStmt + " : group_by_function setsStmt");
	
	setsRs = setsStmt.executeQuery();

	ArrayList<HashMap<String, Object>> setsList = new ArrayList<HashMap<String, Object>>();
	while(setsRs.next()){
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("부서ID", setsRs.getInt("department_id"));
		m.put("직원ID", setsRs.getString("job_id"));
		m.put("인원", setsRs.getInt("count(*)"));
		setsList.add(m);
	}

	System.out.println(setsList + " : group_by_function setsList");
	
	// rollup
	// rollup() 안에 있는 속성에서 앞에있는 속성을 기준으로 뒤에 있는 속성을 group by 한것과 앞 속성 별로 총합을 표시한것 
	PreparedStatement rollupStmt = null;
	ResultSet rollupRs = null;
	String rollupSql = "select department_id, job_id, count(*) from employees group by rollup(department_id, job_id)";
	rollupStmt = conn.prepareStatement(rollupSql);
	
	System.out.println(rollupStmt + " : group_by_function rollupStmt");
	
	rollupRs = rollupStmt.executeQuery();

	ArrayList<HashMap<String, Object>> rollupList = new ArrayList<HashMap<String, Object>>();
	while(rollupRs.next()){
		HashMap<String, Object> m2 = new HashMap<String, Object>();
		m2.put("부서ID", rollupRs.getInt("department_id"));
		m2.put("직원ID", rollupRs.getString("job_id"));
		m2.put("인원", rollupRs.getInt("count(*)"));
		setsList.add(m2);
	}
	// cube
	// cube() 확장함수는 rollup() 확장함수에서 뒤에 속성까지 group by 한것을 추가한것 
	PreparedStatement cubeStmt = null;
	ResultSet cubeRs = null;
	String cubeSql = "select department_id, job_id, count(*) from employees group by cube(department_id, job_id)";
	cubeStmt = conn.prepareStatement(cubeSql);
	
	System.out.println(cubeStmt + " : group_by_function cubeStmt");
	
	cubeRs = cubeStmt.executeQuery();

	ArrayList<HashMap<String, Object>> cubeList = new ArrayList<HashMap<String, Object>>();
	while(cubeRs.next()){
		HashMap<String, Object> m3 = new HashMap<String, Object>();
		m3.put("부서ID", cubeRs.getInt("department_id"));
		m3.put("직원ID", cubeRs.getString("job_id"));
		m3.put("인원", cubeRs.getInt("count(*)"));
		setsList.add(m3);
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<h3>Employees table GROUP BY GROUPING SETS Test</h3>
	<table border="1">
		<tr>
			<th>부서ID</th>
			<th>직무</th>
			<th>인원</th>
		</tr>
		<%
			for(HashMap<String,Object> m : setsList){
		%>
				<tr>
					<td><%=(Integer)(m.get("부서ID"))%></td>
					<td><%=(String)(m.get("직원ID"))%></td>
					<td><%=(Integer)(m.get("인원"))%></td>
				</tr>
		<%
			}
		 %>
	</table>
	
	<h3>Employees table GROUP BY ROLLUP Test</h3>
	<table border="1">
		<tr>
			<th>부서ID</th>
			<th>직무</th>
			<th>인원</th>
		</tr>
		<%
			for(HashMap<String,Object> m2 : setsList){
		%>
				<tr>
					<td><%=(Integer)m2.get("부서ID")%></td>
					<td><%=(String)m2.get("직원ID")%></td>
					<td><%=(Integer)m2.get("인원")%></td>
				</tr>
		<%
			}
		 %>
	</table>
	<h3>Employees table GROUP BY CUBE Test</h3>
	<table border="1">
		<tr>
			<th>부서ID</th>
			<th>직무</th>
			<th>인원</th>
		</tr>
		<%
			for(HashMap<String,Object> m3 : setsList){
		%>
				<tr>
					<td><%=(Integer)m3.get("부서ID")%></td>
					<td><%=(String)m3.get("직원ID")%></td>
					<td><%=(Integer)m3.get("인원")%></td>
				</tr>
		<%
			}
		 %>
	</table>
</body>
</html>