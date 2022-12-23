// decay factor: 30 second half life
// =0.5^(1/30)
const lambda = Math.pow(0.5, 1 / 2);

// Continuous frecency with no recomputations.
// Source: https://wiki.mozilla.org/User:Jesse/NewFrecency
export function updateFdate(
  fdate: Date,
  points: number,
  now: Date = new Date()
): Date {
  return pointsToFdate(fdateToPoints(fdate, now) + points, now);
}

export function pointsToFdate(points: number, now: Date = new Date()): Date {
  return new Date(
    now.getTime() + ((-1.0 * Math.log(points)) / Math.log(lambda)) * 1000
  );
}

export function fdateToPoints(fdate: Date, _now: Date = new Date()): number {
  return Math.pow(lambda, (_now.getTime() - fdate.getTime()) / 1000);
}

(window as any).updateFdate = updateFdate;
(window as any).pointsToFdate = pointsToFdate;
(window as any).fdateToPoints = fdateToPoints;
