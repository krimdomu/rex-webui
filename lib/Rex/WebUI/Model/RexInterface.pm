
package Rex::WebUI::Model::RexInterface;

use strict;

use Rex::Config;
use Data::Dumper;

# global callback used to override / hook into Rex::Logger class
our $LOG_CALLBACK;

use Rex::Rexfile;


sub new { bless {}, shift }

sub get_task
{
	my ($self, $task) = @_;

   my ($task_obj) = grep { $_->name eq $task } @{ $self->rexfile->get_tasks };

   if($task_obj) {

		$task = {
			%{$task_obj->get_data},
			name 		=> $task,
		};

		return $task;
	}
	else {

		warn "task '$task' not found";

		return undef;
	}
}

sub rexfile {
   my ($self) = @_;
   return $self->{__rexfile__};
}

sub get_tasks
{
	my $self = shift;

	my $tasks;

	if ($tasks = $self->{tasks}) {

		$self->log->debug("Tasks already loaded");;
	}
	else {

		$tasks = $self->rexfile->get_tasks;

	}

	return $tasks;
}

sub get_servers
{
	my $self = shift;

	my $servers = [];


	# expand server list into hashrefs, adding info from db if available
	# TODO: add db interface
	foreach my $server (@$servers) {
		
		$server = { name => $server};
	}
	
	return $servers;
}

sub load_rexfile
{
	my ($self, $rexfile) = @_;

   $self->{__rexfile__} = Rex::Rexfile->new(file => $rexfile);

   $self->{tasks} = undef;
   delete $self->{tasks};

   $self->{tasklist} = undef;
   delete $self->{tasklist};
}

sub run_task
{
	my ($self, $task, $temp_logfile) = @_;

	$::QUIET = 1;

	Rex::Config->set_log_filename($temp_logfile) if $temp_logfile;

   my $result = $self->rexfile->run_task($task);

	Rex::Logger::info("DONE");
	
	return $result;
}

sub register_log_callback
{
	my ($self, $callback) = @_;

	$LOG_CALLBACK = $callback;
}

sub release_log_callback
{
	my ($self) = shift;

	$LOG_CALLBACK = undef;
}


#sub Rex::Logger::info
#{
#	my ($msg, $type) = @_;
#
#	return unless $LOG_CALLBACK;
#
#	warn "XXX INFO: $msg";
#
#	if(defined($type)) {
#		$msg = Rex::Logger::format_string($msg, uc($type));
#	}
#	else {
#		$msg = Rex::Logger::format_string($msg, "INFO");
#	}
#
#	$LOG_CALLBACK->($msg);
#}
#
#sub Rex::Logger::debug
#{
#	my ($msg, $type) = @_;
#
#	return unless $LOG_CALLBACK;
#
#	warn "XXX DEBUG: $msg";
#
#	$msg = Rex::Logger::format_string($msg, "DEBUG");
#	$LOG_CALLBACK->($msg);
#}


1;

