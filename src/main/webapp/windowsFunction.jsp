<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
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
	
	// ===================페이지=====================
	int currentPage = 1;
	if(request.getParameter("currentPage") != null){
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	
	// 전체행
	int totalRow = 0;
	String totalRowSql = "select count(*) from employees";
	PreparedStatement totalRowStmt = conn.prepareStatement(totalRowSql);
	
	System.out.println(totalRowStmt + " windowsFunction totalRowStmt");
	
	ResultSet totalRowRs = totalRowStmt.executeQuery();
	if(totalRowRs.next()){
		totalRow = totalRowRs.getInt(1); // 1 = count(*)
	}
	
	// 한페이지당 행개수
	int rowPerPage = 10;
	
	// 시작행 = ((현재 페이지 - 1) x 페이지당 개수 10개) + 1 ex) 2페이지 > 11번 행~ 20번 행
	int beginRow = (currentPage - 1) * rowPerPage + 1;
	
	// 마지막행 = 시작행 + (페이지당 개수 10개 - 1 = 9);
	int endRow = beginRow + (rowPerPage - 1);
	if(endRow > totalRow){
		endRow = totalRow;
	}
	
	// 각 페이지 선택 버튼 몇개 표시?
	int pagePerPage = 10;
	
	// 마지막 페이지
	int lastPage = totalRow / rowPerPage;
	if(totalRow % rowPerPage != 0){ // 페이지가 떨어지지않아 잔여 행이 있다면 
		lastPage = lastPage + 1; // 1 추가, 잔여 행을 lastPage에 배치
	}
	
	// 페이지 선택 버튼 최소값 >> 1~10 / 11~20 에서 1 / 11 / 21 ,,,
	int minPage = ((currentPage-1) / pagePerPage * pagePerPage) + 1;
	
	// 페이지 선택 버튼 최대값 >> 1~10 / 11~20 에서 10 / 20 / 30 ,,,
	int maxPage = minPage + (pagePerPage - 1);
	if(maxPage > lastPage){ // ex) lastPage는 27, maxPage가 30(21~30) 일 경우
		maxPage = lastPage;  // maxPage를 lastPage == 27로 한다. 
	}
	
	// ===========================================
	/*			
	분석함수
	select last_name, salary, count(*) over(partition by null)
	from employees;

	그룹바이 : 조회에 사용되는 원본 결과셋을 변경
	분석함수 : 원본 결과셋의 변경없이,계산용 임시집합(셋)을 만들어 계산(집계,통계)에 사용 후 
			그 결과를 select절에 값으로 추가
	(시스템 내부적으로는 스칼라 서브쿼리를 사용 > 분석함수를 제공하지 않는 RDBS에서는 스칼라 서브쿼리를 사용)

	분석함수의 종류
		1. 분석용 집계함수 
		2. 랭크함수
		3. 비율함수
		
	분석용 집계 함수
	select employee_id, last_name, salary, 
	    round(avg(salary) over()) 전체급여평균,
	    sum(salary) over() 전체급여합계,
	    count(*) over() 전체사원수
	from employees;
	*/			
	PreparedStatement winStmt = null;
	ResultSet winRs = null;
	String winSql = "select 번호, 사원ID, 이름, 급여, 전체급여평균, 전체급여합계, 전체사원수 from (select rownum 번호, employee_id 사원ID, last_name 이름, salary 급여, round(avg(salary) over()) 전체급여평균, sum(salary) over() 전체급여합계, count(*) over() 전체사원수 from employees) where 번호 between ? and ?";
	winStmt = conn.prepareStatement(winSql);
	winStmt.setInt(1, beginRow);
	winStmt.setInt(2, endRow);
	
	System.out.println(winStmt + " windowsFunction winStmt");
	
	winRs = winStmt.executeQuery();
	
	ArrayList<HashMap<String, Object>> winList = new ArrayList<HashMap<String, Object>>();
	while(winRs.next()){
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("사원ID", winRs.getInt("사원ID"));
		m.put("이름", winRs.getString("이름"));
		m.put("급여", winRs.getInt("급여"));
		m.put("전체급여평균", winRs.getInt("전체급여평균"));
		m.put("전체급여합계", winRs.getInt("전체급여합계"));
		m.put("전체사원수", winRs.getInt("전체사원수"));
		winList.add(m);
	}

	System.out.println(winList + " : windowsFunction winList");
	
%>			
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>분석 함수</title>
</head>
<body>
	<h3>분석함수</h3>
	<table border="1">
		<tr>
			<th>사원ID</th>
			<th>이름</th>
			<th>급여</th>
			<th>전체급여평균</th>
			<th>전체급여합계</th>
			<th>전체사원수</th>
		</tr>
		<%
			for(HashMap<String,Object> m : winList){
		%>
				<tr>
					<td><%=(Integer)(m.get("사원ID"))%></td>
					<td><%=(String)(m.get("이름"))%></td>
					<td><%=(Integer)(m.get("급여"))%></td>
					<td><%=(Integer)(m.get("전체급여평균"))%></td>
					<td><%=(Integer)(m.get("전체급여합계"))%></td>
					<td><%=(Integer)(m.get("전체사원수"))%></td>
				</tr>
		<%
			}
		 %>
	</table>
	<!-- 페이지 -->
	<%	
		// 첫페이지가 아닐 경우 이전 버튼 표시 == 첫 페이지에선 표시 x
		if(minPage > 1){
	%>
			<a href="<%=request.getContextPath()%>/windowsFunction.jsp?currentPage=<%=minPage-rowPerPage%>">이전</a>&nbsp;
	<%
		}
		
		// 첫페이지부터 마지막 페이지까지 버튼 표시
		// 현재 페이지 일 경우 숫자만 표시 / 나머지 페이지는 링크로 표시
		for(int i = minPage; i<=maxPage; i++){
			if(i == currentPage){
	%>
				<span><%=i%></span>
	<%	
			} else {
	%>
				<a href="<%=request.getContextPath()%>/windowsFunction.jsp?currentPage=<%=i%>"><%=i%></a>&nbsp;
	<%			
			}
		}
		// 각 페이지 표시버튼이 마지막이 아닌 경우 다음 버튼 표시 == 마지막 페이지에선 표시x
		if(maxPage != lastPage){
	%>
			<a href="<%=request.getContextPath()%>/windowsFunction.jsp?currentPage=<%=minPage+rowPerPage%>">다음</a>&nbsp;
	<%
		}
	%>	
</body>
</html>