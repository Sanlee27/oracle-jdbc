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
	
	// ===========================================
	/*
	- exists, not exists
		- where exists 뒤의 서브쿼리 조인의 결과 있으면 참 : 조인된 행이 있으면 참
		- exists는 서브쿼리의 결과가 있는지 없는지 체크 하기때문에 다음과 같이 서브쿼리를 만드는 경우가 많다 )) exists (select 1 from emp e where d.deptno = e.deptno)
		- 조인과의 차이 : 조인문은 두테이블을 이상을 합친 결과가 결과셋으로 사용되지만 
					  exists연산자는 메인쿼리에 사용된 테이블만 결과셋으로 사용하고 합쳐진 테이블(조인된 계산 결과셋)은 계산용으로(참/거짓)만 사용된다.
	*/
	// ===========where exists===============
	PreparedStatement stmt = null;
	ResultSet rs = null;
	String sql = "select e.employee_id 사원ID, e.first_name 이름, e.department_id 부서ID from employees e where exists (select * from departments d where d.department_id = e.department_id)"; 
	
	stmt = conn.prepareStatement(sql);
	
	System.out.println(stmt + " : exists_not_exists_list stmt");
	
	rs = stmt.executeQuery();
	
	ArrayList<HashMap<String, Object>> list = new ArrayList<HashMap<String, Object>>();
	while(rs.next()){
		HashMap<String, Object> r = new HashMap<String, Object>();
		r.put("사원ID", rs.getString("사원ID"));
		r.put("이름", rs.getString("이름"));
		r.put("부서ID", rs.getString("부서ID"));
		list.add(r);
	}
	// ===========where not exists===============
	PreparedStatement nStmt = null;
	ResultSet nRs = null;
	String nSql = "select e.employee_id 사원ID, e.first_name 이름, e.department_id 부서ID from employees e where not exists (select * from departments d where d.department_id = e.department_id)"; 
	
	nStmt = conn.prepareStatement(nSql);
	
	System.out.println(nStmt + " : exists_not_exists_list nStmt");
	
	nRs = nStmt.executeQuery();
	
	ArrayList<HashMap<String, Object>> nList = new ArrayList<HashMap<String, Object>>();
	while(nRs.next()){
		HashMap<String, Object> r2 = new HashMap<String, Object>();
		r2.put("사원ID", nRs.getString("사원ID"));
		r2.put("이름", nRs.getString("이름"));
		r2.put("부서ID", nRs.getString("부서ID"));
		nList.add(r2);
	}
%>			
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<h3>Exist</h3>
	<table border="1">
		<tr>
			<th>사원ID</th>
			<th>이름</th>
			<th>부서ID</th>
		</tr>
		<%
			for(HashMap<String,Object> r : list){
		%>
				<tr>
					<td><%=(String)(r.get("사원ID"))%></td>
					<td><%=(String)(r.get("이름"))%></td>
					<td><%=(String)(r.get("부서ID"))%></td>
				</tr>
		<%
			}
		 %>
	</table>
	
	<h3>Not Exist</h3>
	<table border="1">
		<tr>
			<th>사원ID</th>
			<th>이름</th>
			<th>부서ID</th>
		</tr>
		<%
			for(HashMap<String,Object> r2 : nList){
		%>
				<tr>
					<td><%=(String)(r2.get("사원ID"))%></td>
					<td><%=(String)(r2.get("이름"))%></td>
					<td><%=(String)(r2.get("부서ID"))%></td>
				</tr>
		<%
			}
		 %>
	</table>
</body>
</html>