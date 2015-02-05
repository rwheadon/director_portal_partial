jQuery ->
	$('#reservations_index').dataTable
		bFilter: true
		bCaseInsensitive: false
		bPaginate: false
		bJQueryUI: true
		iDisplayLength:100
		aoColumnDefs: [
		  {
		     bSortable: true,
		     aTargets: [ -1,-2,-3]
			 sDom: "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>",
			 sPaginationType: "bootstrap"
		  }
		]
	
	$('#reservation_eventzz').change ->
		ev = $('#reservation_event').val();
		alert( ev );
		$('#reg_filter_form').submit();
