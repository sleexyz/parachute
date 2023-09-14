"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g;
    return g = { next: verb(0), "throw": verb(1), "return": verb(2) }, typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (g && (g = 0, op[0] && (_ = 0)), _) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
Object.defineProperty(exports, "__esModule", { value: true });
var tasks_1 = require("@google-cloud/tasks");
var functions = require("@google-cloud/functions-framework");
// GCloud
var PROJECT_ID = "slowdown-375014";
var LOCATION = 'us-central1';
var QUEUE_NAME = 'slowdown-unpause-queue';
// OneSignal
var APP_ID = "b1bee63a-1006-42bd-bd66-5a803c64f63c";
var REST_API_KEY = "ZjQ5NmY0MDctZDljNi00ODljLWJjODItMWEzMGI1NWNiZTRl";
functions.http('register_activity_refresh', function (req, res) { return __awaiter(void 0, void 0, void 0, function () {
    var activityId, refreshDate, e_1, taskName;
    return __generator(this, function (_a) {
        switch (_a.label) {
            case 0:
                activityId = req.body.activityId;
                refreshDate = req.body.refreshDate;
                _a.label = 1;
            case 1:
                _a.trys.push([1, 3, , 4]);
                return [4 /*yield*/, ActivityRefreshService.shared.cancelActivityRefreshTask({ activityId: activityId })];
            case 2:
                _a.sent();
                return [3 /*break*/, 4];
            case 3:
                e_1 = _a.sent();
                console.log(e_1);
                return [3 /*break*/, 4];
            case 4: return [4 /*yield*/, ActivityRefreshService.shared.registerActivityRefreshTask({ activityId: activityId, refreshDate: refreshDate })];
            case 5:
                taskName = _a.sent();
                res.json({
                    taskName: taskName
                });
                return [2 /*return*/];
        }
    });
}); });
functions.http('cancel_activity_refresh', function (req, res) { return __awaiter(void 0, void 0, void 0, function () {
    var activityId;
    return __generator(this, function (_a) {
        switch (_a.label) {
            case 0:
                activityId = req.body.activityId;
                return [4 /*yield*/, ActivityRefreshService.shared.cancelActivityRefreshTask({ activityId: activityId })];
            case 1:
                _a.sent();
                res.json({});
                return [2 /*return*/];
        }
    });
}); });
var client = new tasks_1.CloudTasksClient();
function hashCode(str) {
    var hash = 0, i, chr;
    if (str.length === 0)
        return hash;
    for (i = 0; i < str.length; i++) {
        chr = str.charCodeAt(i);
        hash = ((hash << 5) - hash) + chr;
        hash |= 0; // Convert to 32bit integer
    }
    return hash;
}
var ActivityRefreshService = /** @class */ (function () {
    function ActivityRefreshService() {
    }
    ActivityRefreshService.prototype.registerActivityRefreshTask = function (_a) {
        var activityId = _a.activityId, refreshDate = _a.refreshDate;
        return __awaiter(this, void 0, void 0, function () {
            var payload, url, parent, taskId, task, request, response;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        payload = JSON.stringify({
                            event: 'update',
                            event_updates: {
                                isConnected: true
                            },
                            name: 'Internal OneSignal Notification Name',
                            contents: { en: 'English Message' },
                            headings: { en: 'English Message' },
                            sound: 'beep.wav',
                            stale_date: refreshDate + 1000 * 60 * 60 * 8,
                            dismissal_date: refreshDate + 1000 * 60 * 60 * 24 * 7,
                            priority: 10
                        });
                        url = "https://onesignal.com/api/v1/apps/".concat(APP_ID, "/live_activities/").concat(activityId, "/notifications");
                        parent = client.queuePath(PROJECT_ID, LOCATION, QUEUE_NAME);
                        taskId = "".concat(activityId, "--").concat(hashCode(refreshDate.toString()));
                        task = {
                            name: client.taskPath(PROJECT_ID, LOCATION, QUEUE_NAME, taskId),
                            httpRequest: {
                                url: url,
                                headers: {
                                    accept: 'application/json',
                                    'Content-Type': 'application/json',
                                    Authorization: "Basic ".concat(REST_API_KEY, "}")
                                },
                                httpMethod: 'POST',
                                body: Buffer.from(payload).toString('base64')
                            },
                            // The time when the task is scheduled to be attempted.
                            scheduleTime: {
                                seconds: refreshDate / 1000,
                            },
                        };
                        // Send create task request.
                        console.log('Sending task:');
                        console.log(task);
                        request = { parent: parent, task: task };
                        return [4 /*yield*/, client.createTask(request)];
                    case 1:
                        response = (_b.sent())[0];
                        console.log("Created task ".concat(response.name));
                        return [2 /*return*/, response.name];
                }
            });
        });
    };
    ActivityRefreshService.prototype.cancelActivityRefreshTask = function (_a) {
        var _b;
        var activityId = _a.activityId;
        return __awaiter(this, void 0, void 0, function () {
            var resp, _i, _c, task, taskId;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0: return [4 /*yield*/, client.listTasks({
                            parent: client.queuePath(PROJECT_ID, LOCATION, QUEUE_NAME),
                        })];
                    case 1:
                        resp = _d.sent();
                        _i = 0, _c = resp[0];
                        _d.label = 2;
                    case 2:
                        if (!(_i < _c.length)) return [3 /*break*/, 5];
                        task = _c[_i];
                        taskId = ((_b = task.name) === null || _b === void 0 ? void 0 : _b.split('/').pop()) || '';
                        if (!taskId.includes(activityId)) return [3 /*break*/, 4];
                        return [4 /*yield*/, client.deleteTask({ name: task.name })];
                    case 3:
                        _d.sent();
                        console.log("Deleted task ".concat(task.name));
                        _d.label = 4;
                    case 4:
                        _i++;
                        return [3 /*break*/, 2];
                    case 5: return [2 /*return*/];
                }
            });
        });
    };
    ActivityRefreshService.shared = new ActivityRefreshService();
    return ActivityRefreshService;
}());
