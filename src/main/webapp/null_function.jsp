<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*"%>
<%@ page import = "java.util.*"%>   
<%
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dburl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbuser = "gdj66";
	String dbpw = "java1234";
	
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	System.out.println(conn);
	
	// ===========================================
	/*
   		null 관련 함수 -> null을 다른값으로 치환
			1) nvl()
			2) nvl2()
			3) nullif()
			4) coalesce()

		select 20+null  from emp; -- 숫자+null -> null이 된다 -> null을 숫자값을 치환이 필요하다
	*/
	
	// =============== nvl
	// nvl(값1, 값2) : 값1이 null이 아니면 값1을 반환, 값1이 null이면 값2를 반환한다
	PreparedStatement nvlStmt = null;
	ResultSet nvlRs = null;
	String nvlSql = "select 이름, nvl(일분기, 0) 일분기 from 실적";
	nvlStmt = conn.prepareStatement(nvlSql);
	
	System.out.println(nvlStmt + " : null_function nvlStmt");
	
	nvlRs = nvlStmt.executeQuery();

	ArrayList<HashMap<String, Object>> nvlList = new ArrayList<HashMap<String, Object>>();
	while(nvlRs.next()){
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("이름", nvlRs.getString("이름"));
		m.put("일분기", nvlRs.getString("일분기"));
		nvlList.add(m);
	}

	System.out.println(nvlList + " : null_function nvlList");
	// !! 서로 다른 세션에서 접속할때는 커밋을 꼭해야된다!!. 
			
	// =============== nvl2
	// nvl2(값1, 값2, 값3) : 값1이 null아니면 값2반환, 값1이 null이면 값3을 반환
	PreparedStatement nvl2Stmt = null;
	ResultSet nvl2Rs = null;
	String nvl2Sql = "select 이름, nvl2(일분기, 'success', 'fail') 일분기 from 실적";
	nvl2Stmt = conn.prepareStatement(nvl2Sql);
	
	System.out.println(nvl2Stmt + " : null_function nvl2Stmt");
	
	nvl2Rs = nvl2Stmt.executeQuery();

	ArrayList<HashMap<String, Object>> nvl2List = new ArrayList<HashMap<String, Object>>();
	while(nvl2Rs.next()){
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("이름", nvl2Rs.getString("이름"));
		m.put("일분기", nvl2Rs.getString("일분기"));
		nvl2List.add(m);
	}

	System.out.println(nvl2List + " : null_function nvl2List");
	
	// =============== nullif
	// nullif(값1, 값2) : 값1과 값2가 같으면 null을 반환 (null이 아닌값이 null로 치환에 사용)
	PreparedStatement nullIfStmt = null;
	ResultSet nullIfRs = null;
	String nullIfSql = "select 이름, nullif(사분기, 100) 사분기 from 실적";
	nullIfStmt = conn.prepareStatement(nullIfSql);
	
	System.out.println(nullIfStmt + " : null_function nullIfStmt");
	
	nullIfRs = nullIfStmt.executeQuery();

	ArrayList<HashMap<String, Object>> nullIfList = new ArrayList<HashMap<String, Object>>();
	while(nullIfRs.next()){
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("이름", nullIfRs.getString("이름"));
		m.put("사분기", nullIfRs.getInt("사분기"));
		nullIfList.add(m);
	}

	System.out.println(nullIfList + " : null_function nullIfList");
	
	// =============== coalesce
	// coalesce(값1, 값2, 값3, .....) : 입력값 중 null아닌 첫번째값을 반환
	PreparedStatement coalesceStmt = null;
	ResultSet coalesceRs = null;
	String coalesceSql = "select 이름, coalesce(일분기, 이분기, 삼분기, 사분기) 첫실적 from 실적";
	coalesceStmt = conn.prepareStatement(coalesceSql);
	
	System.out.println(coalesceStmt + " : null_function coalesceStmt");
	
	coalesceRs = coalesceStmt.executeQuery();

	ArrayList<HashMap<String, Object>> coalesceList = new ArrayList<HashMap<String, Object>>();
	while(coalesceRs.next()){
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("이름", coalesceRs.getString("이름"));
		m.put("첫실적", coalesceRs.getString("첫실적"));
		coalesceList.add(m);
	}

	System.out.println(coalesceList + " : null_function coalesceList");  
%>    
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>null 함수</title>
</head>
<body>
	<h3>nvl</h3>
	<table border="1">
		<tr>
			<th>이름</th>
			<th>일분기</th>
		</tr>
		<%
			for(HashMap<String, Object> m : nvlList) {
		%>
				<tr>
					<td><%=m.get("이름")%></td>
					<td><%=m.get("일분기")%></td>
				</tr>
		<%		
			}
		%>
	</table>
	<h3>nvl2</h3>
	<table border="1">
		<tr>
			<th>이름</th>
			<th>일분기</th>
		</tr>
		<%
			for(HashMap<String, Object> m : nvl2List) {
		%>
				<tr>
					<td><%=m.get("이름")%></td>
					<td><%=m.get("일분기")%></td>
				</tr>
		<%		
			}
		%>
	</table>
	<h3>nullIf</h3>
	<table border="1">
		<tr>
			<th>이름</th>
			<th>사분기</th>
		</tr>
		<%
			for(HashMap<String, Object> m : nullIfList) {
		%>
				<tr>
					<td><%=m.get("이름")%></td>
					<td><%=m.get("사분기")%></td>
				</tr>
		<%		
			}
		%>
	</table>
	<h3>coalesce</h3>
	<table border="1">
		<tr>
			<th>이름</th>
			<th>첫실적</th>
		</tr>
		<%
			for(HashMap<String, Object> m : coalesceList) {
		%>
				<tr>
					<td><%=m.get("이름")%></td>
					<td><%=m.get("첫실적")%></td>
				</tr>
		<%		
			}
		%>
	</table>
</body>
</html>