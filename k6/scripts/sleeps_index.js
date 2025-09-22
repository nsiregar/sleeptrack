import http from 'k6/http';
import { check, sleep } from 'k6';

// These are the test options.
export const options = {
  // This stages configuration will ramp up from 1 to 10 virtual users over 30s,
  // stay at 10 users for 1m, then ramp down to 0 over 30s.
  stages: [
    { duration: '30s', target: 50 },
    { duration: '1m', target: 200 },
    { duration: '30s', target: 0 },
  ],
  // These are the pass/fail thresholds for the test.
  thresholds: {
    http_req_failed: ['rate<0.01'],   // http errors should be less than 1%
    http_req_duration: ['p(95)<200'], // 95% of requests should be below 200ms
  },
};

export default function () {
  // The user_id=1 parameter will authenticate as our main benchmark user.
  const res = http.get('http://host.docker.internal:80/api/v1/users/1/sleeps');

  // Check that the request was successful.
  check(res, {
    'status was 200': (r) => r.status == 200,
    'transaction time OK': (r) => r.timings.duration < 200,
  });

  // Wait for 1 second before the next virtual user iteration.
  sleep(1);
}

