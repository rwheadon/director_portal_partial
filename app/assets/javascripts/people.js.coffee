jQuery ->
	$('#people_index').dataTable
		bFilter: true
		bPaginate: false
		bJQueryUI: true
		iDisplayLength:500
		aoColumnDefs: [
		  {
		     bSortable: true,
		     aTargets: [ -1,-2,-3],
			 sDom: "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>",
			 sPaginationType: "bootstrap"
		  }
		]