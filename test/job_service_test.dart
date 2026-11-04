import 'package:flutter_test/flutter_test.dart';
import 'package:hire_me/core/constants/app_constants.dart';
import 'package:hire_me/shared/services/job_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('JobService & Jobs Feature Tests', () {
    late JobService jobService;

    setUp(() {
      jobService = JobService.instance;
      jobService.resetSampleJobs();
    });

    test('Initial sample jobs contain completed jobs done before', () {
      final jobs = jobService.currentJobs;
      final completedJobs = jobs.where((j) => j.status == JobStatus.completed).toList();

      expect(completedJobs.isNotEmpty, true, reason: 'Dashboard should have jobs done before initially');
      expect(completedJobs.length, greaterThanOrEqualTo(3));
      expect(completedJobs.first.title.isNotEmpty, true);
    });

    test('Worker can reject a job request', () async {
      final initialPending = jobService.currentJobs.where((j) => j.status == JobStatus.pending).toList();
      expect(initialPending.isNotEmpty, true);

      final jobToReject = initialPending.first;
      await jobService.rejectJob(jobToReject.id, reason: 'Declined by worker');

      final updatedJob = jobService.currentJobs.firstWhere((j) => j.id == jobToReject.id);
      expect(updatedJob.status, JobStatus.rejected);
      expect(updatedJob.cancellationReason, 'Declined by worker');

      // Ensure it is no longer listed as pending
      final pendingAfter = jobService.currentJobs.where((j) => j.status == JobStatus.pending).toList();
      expect(pendingAfter.any((j) => j.id == jobToReject.id), false);
    });

    test('Worker can accept and complete a job request', () async {
      final initialPending = jobService.currentJobs.where((j) => j.status == JobStatus.pending).toList();
      expect(initialPending.isNotEmpty, true);

      final job = initialPending.first;
      await jobService.acceptJob(job.id, workerId: 'worker-1', workerName: 'Rajesh Kumar');

      var updated = jobService.currentJobs.firstWhere((j) => j.id == job.id);
      expect(updated.status, JobStatus.inProgress);
      expect(updated.workerId, 'worker-1');

      await jobService.completeJob(job.id, finalAmount: 500.0);
      updated = jobService.currentJobs.firstWhere((j) => j.id == job.id);
      expect(updated.status, JobStatus.completed);
      expect(updated.finalAmount, 500.0);
    });
  });
}
