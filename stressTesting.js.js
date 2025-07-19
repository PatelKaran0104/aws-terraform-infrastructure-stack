import http from 'k6/http';
import { sleep, check } from 'k6';

export let options = {
  stages: [
    { duration: '30s', target: 100 },   // quick ramp to 100 VUs
    { duration: '2m', target: 300 },    // sustained load of 300 VUs
    { duration: '1m', target: 500 },    // spike to 500 VUs
    { duration: '3m', target: 500 },    // hold at 500 VUs (should trigger scaling)
    { duration: '30s', target: 0 },     // quick ramp-down
  ],
  thresholds: {
    http_req_failed: ['rate<0.1'],      // Allow more errors under extreme load
    http_req_duration: ['p(95)<3000'],  // More lenient timing
  },
};

export default function () {
  let url = `http://educate-alb-1352261712.us-east-1.elb.amazonaws.com/`;
  
  // Add random headers to simulate different browsers/devices
  let headers = {
    'User-Agent': Math.random() > 0.5 ? 
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36' :
      'Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    'Accept-Language': Math.random() > 0.5 ? 'en-US,en;q=0.5' : 'es-ES,es;q=0.8',
    'Cache-Control': Math.random() > 0.7 ? 'no-cache' : 'max-age=0'
  };
  
  let res = http.get(url, { headers: headers });
  
  check(res, {
    'status is 200': (r) => r.status === 200,
    'status is not 500': (r) => r.status !== 500,
    'body is not empty': (r) => r.body.length > 0,
    'response time < 5s': (r) => r.timings.duration < 5000,
    'no connection errors': (r) => !r.error,
  });

  // Shorter sleep = more aggressive load
  sleep(Math.random() * 0.5 + 0.2); // 0.2-0.7 seconds (much more aggressive)
}
