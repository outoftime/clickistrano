$(function() {
	var $progress = $('#progress');
	var $log = $('#log');
	var $status = $('#status');
	var position = 0;
	$log.everyTime(100, 'update', function() {
		$.getJSON('/status', { start: position }, function(data) {
			if(data.status != 'INPROGRESS') {
				$log.stopTime('update');
			}
			var status_message;
			var status_class;
			switch(data.status) {
			case 'INPROGRESS':
				status_message = 'In Progress';
				status_class = 'in_progress';
				break;
			case 'DONE':
				status_message = 'Done';
				status_class = 'success';
				break;
			case 'FAILED':
				status_message = 'Failed';
				status_class = 'failed';
				break;
			case 'ERROR':
				status_message = 'Error';
				status_class = 'failed';
				break;
			}
			$status.removeClass();
			$status.addClass(status_class);
			$status.text(status_message);
			position = data.position
			$log.append(data.log);
			$progress.scrollTop($log.height());
		});
	});	
});
