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
		- 분석함수
			- 1) 분석집계함수_partition by
				- 1-1) partition by null인 경우
				- 1-2) partition by null이 아닌 경우
			- 2) 순위함수_partiton by ... order by ( + windowing ,,,)__rank
			- 3) 분석순서함수_first/last value
			- 4) 분석비율함수_ntile~
	*/
	
	// ===========순위함수_rank 3종_rank===============
	/*
		- rank() over
		- dense_rank() over
		- row number() over
	*/
	PreparedStatement rankStmt = null;
	ResultSet rankRs = null;
	String rankSql = "select rownum, 이름, 급여, 순위 from (select first_name 이름, salary 급여, rank() over(order by salary) 순위 from employees)"; 
	// 공동순위 2등이 2명일경우 3등은 건너뛰고 4등 표시
	
	rankStmt = conn.prepareStatement(rankSql);
	
	System.out.println(rankStmt + " : rank_ntil_list rankStmt");
	
	rankRs = rankStmt.executeQuery();
	
	ArrayList<HashMap<String, Object>> rankList = new ArrayList<HashMap<String, Object>>();
	while(rankRs.next()){
		HashMap<String, Object> r = new HashMap<String, Object>();
		r.put("rownum", rankRs.getInt("rownum"));
		r.put("이름", rankRs.getString("이름"));
		r.put("급여", rankRs.getInt("급여"));
		r.put("순위", rankRs.getInt("순위"));
		rankList.add(r);
	}
	
	// ===========순위함수_rank 3종_dense_rank===============
	/*
		- rank() over
		- dense_rank() over
		- row_number() over
	*/
	PreparedStatement dRankStmt = null;
	ResultSet dRankRs = null;
	String dRankSql = "select rownum, 이름, 급여, 순위 from (select first_name 이름, salary 급여, dense_rank() over(order by salary) 순위 from employees)"; 
	// 공동순위 2등이 2명일경우 4등을 3등으로 표시,, 빈 등수 없게
	
	dRankStmt = conn.prepareStatement(dRankSql);
	
	System.out.println(dRankStmt + " : rank_ntil_list dRankStmt");
	
	dRankRs = dRankStmt.executeQuery();
	
	ArrayList<HashMap<String, Object>> dRankList = new ArrayList<HashMap<String, Object>>();
	while(dRankRs.next()){
		HashMap<String, Object> dr = new HashMap<String, Object>();
		dr.put("rownum", dRankRs.getInt("rownum"));
		dr.put("이름", dRankRs.getString("이름"));
		dr.put("급여", dRankRs.getInt("급여"));
		dr.put("순위", dRankRs.getInt("순위"));
		dRankList.add(dr);
	}
	
	// ===========순위함수_rank 3종_row_number===============
		/*
			- rank() over
			- dense_rank() over
			- row number() over
		*/
		PreparedStatement rNumStmt = null;
		ResultSet rNumRs = null;
		String rNumSql = "select rownum, 이름, 급여, 순위 from (select first_name 이름, salary 급여, row_number() over(order by salary) 순위 from employees)"; 
		// 공동순위 2등이 2명일경우에도 1,2등 나눠서
		
		rNumStmt = conn.prepareStatement(rNumSql);
		
		System.out.println(rNumStmt + " : rank_ntil_list rNumStmt");
		
		rNumRs = rNumStmt.executeQuery();
		
		ArrayList<HashMap<String, Object>> rNumList = new ArrayList<HashMap<String, Object>>();
		while(rNumRs.next()){
			HashMap<String, Object> rn = new HashMap<String, Object>();
			rn.put("rownum", rNumRs.getInt("rownum"));
			rn.put("이름", rNumRs.getString("이름"));
			rn.put("급여", rNumRs.getInt("급여"));
			rn.put("순위", rNumRs.getInt("순위"));
			rNumList.add(rn);
		}
	
	// ===========분석비율함수_ntile===============
		
		PreparedStatement nTileStmt = null;
		ResultSet nTileRs = null;
		String nTileSql = "select rownum, 이름, 급여, 그룹 from (select first_name 이름, salary 급여, ntile(3) over(order by salary desc) 그룹 from employees)"; 
		/*
		salary를 내림차순 후 10개의 그룹으로 나누어 어느 그룹에 속하는지 ntile(10)
		ntile(n) n개의 그룹으로 나눈다
		*/
		nTileStmt = conn.prepareStatement(nTileSql);
		
		System.out.println(nTileStmt + " : rank_ntil_list nTileStmt");
		
		nTileRs = nTileStmt.executeQuery();
		
		ArrayList<HashMap<String, Object>> nTileList = new ArrayList<HashMap<String, Object>>();
		while(nTileRs.next()){
			HashMap<String, Object> nt = new HashMap<String, Object>();
			nt.put("rownum", nTileRs.getInt("rownum"));
			nt.put("이름", nTileRs.getString("이름"));
			nt.put("급여", nTileRs.getInt("급여"));
			nt.put("그룹", nTileRs.getInt("그룹"));
			nTileList.add(nt);
		}
%>	
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>분석 함수</title>
</head>
<body>
	<h3>Employees table rank Test</h3>
	<table border="1">
		<tr>
			<th>번호</th>
			<th>이름</th>
			<th>급여</th>
			<th>순위</th>
		</tr>
		<%
			for(HashMap<String,Object> r : rankList){
		%>
				<tr>
					<td><%=(Integer)(r.get("rownum"))%></td>
					<td><%=(String)(r.get("이름"))%></td>
					<td><%=(Integer)(r.get("급여"))%></td>
					<td><%=(Integer)(r.get("순위"))%></td>
				</tr>
		<%
			}
		 %>
	</table>
	
	<h3>Employees table dense_rank Test</h3>
	<table border="1">
		<tr>
			<th>번호</th>
			<th>이름</th>
			<th>급여</th>
			<th>순위</th>
		</tr>
		<%
			for(HashMap<String,Object> dr : dRankList){
		%>
				<tr>
					<td><%=(Integer)(dr.get("rownum"))%></td>
					<td><%=(String)(dr.get("이름"))%></td>
					<td><%=(Integer)(dr.get("급여"))%></td>
					<td><%=(Integer)(dr.get("순위"))%></td>
				</tr>
		<%
			}
		 %>
	</table>
	
	<h3>Employees table row_number Test</h3>
	<table border="1">
		<tr>
			<th>번호</th>
			<th>이름</th>
			<th>급여</th>
			<th>순위</th>
		</tr>
		<%
			for(HashMap<String,Object> rn : rNumList){
		%>
				<tr>
					<td><%=(Integer)(rn.get("rownum"))%></td>
					<td><%=(String)(rn.get("이름"))%></td>
					<td><%=(Integer)(rn.get("급여"))%></td>
					<td><%=(Integer)(rn.get("순위"))%></td>
				</tr>
		<%
			}
		 %>
	</table>
	
	<h3>Employees table ntile Test</h3>
	<table border="1">
		<tr>
			<th>번호</th>
			<th>이름</th>
			<th>급여</th>
			<th>그룹</th>
		</tr>
		<%
			for(HashMap<String,Object> nt : nTileList){
		%>
				<tr>
					<td><%=(Integer)(nt.get("rownum"))%></td>
					<td><%=(String)(nt.get("이름"))%></td>
					<td><%=(Integer)(nt.get("급여"))%></td>
					<td><%=(Integer)(nt.get("그룹"))%></td>
				</tr>
		<%
			}
		 %>
	</table>
	
</body>
</html>