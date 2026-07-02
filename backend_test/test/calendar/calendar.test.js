import { describe, it, before } from 'node:test';
import assert from 'node:assert/strict';
import { initProto, getProto, BuzzingClient, fullLogin, getConfig, safeDecode, str, isNonZero } from '../../lib/index.js';

let client;
let createdCalendarId = null;
let createdScheduleId = null;

before(async () => {
  await initProto();
  const config = getConfig();
  const result = await fullLogin(new BuzzingClient(), config.phone, config.password);
  client = result.client;
});

describe('calendar', () => {

  it('should get calendar list', async () => {
    const cmdEnum = getProto().lookupEnum('command.Command');
    const CalendarGetListRequest = getProto().lookupType('calendar.CalendarGetListRequest');
    const reqBytes = CalendarGetListRequest.encode(
      CalendarGetListRequest.create({})
    ).finish();
    const res = await client.httpRequest(cmdEnum.values.CALENDAR_GET_LIST, reqBytes);
    assert.ok(res.code === 0 || res.code === 200, `code=${res.code}`);

    const dec = safeDecode(getProto(), 'calendar.CalendarGetListResponse', res.data);
    assert.ok(dec.ok, `decode failed: ${dec.error}`);
    assert.ok(Array.isArray(dec.result.calendars), 'should have calendars array');
  });

  it('should create a calendar', async () => {
    const cmdEnum = getProto().lookupEnum('command.Command');
    const Calendar = getProto().lookupType('entity.Calendar');
    const CalendarCreateRequest = getProto().lookupType('calendar.CalendarCreateRequest');
    const cal = Calendar.create({
      name: `test-calendar-${Date.now()}`,
      desc: 'created by backend test',
      color: 1,
      is_default: false,
    });
    const reqBytes = CalendarCreateRequest.encode(
      CalendarCreateRequest.create({ calendar: cal })
    ).finish();
    const res = await client.httpRequest(cmdEnum.values.CALENDAR_CREATE, reqBytes);
    assert.ok(res.code === 0 || res.code === 200, `code=${res.code}`);

    const dec = safeDecode(getProto(), 'calendar.CalendarCreateResponse', res.data);
    assert.ok(dec.ok, `decode failed: ${dec.error}`);
    assert.ok(dec.result.calendar, 'should have calendar');
    assert.equal(dec.result.calendar.name, cal.name);
    createdCalendarId = str(dec.result.calendar.id);
  });

  it('should search calendars', async () => {
    assert.ok(createdCalendarId);
    const cmdEnum = getProto().lookupEnum('command.Command');
    const CalendarSearchRequest = getProto().lookupType('calendar.CalendarSearchRequest');
    const reqBytes = CalendarSearchRequest.encode(
      CalendarSearchRequest.create({ key: 'test-calendar' })
    ).finish();
    const res = await client.httpRequest(cmdEnum.values.CALENDAR_SEARCH, reqBytes);
    assert.ok(res.code === 0 || res.code === 200, `code=${res.code}`);

    const dec = safeDecode(getProto(), 'calendar.CalendarSearchResponse', res.data);
    assert.ok(dec.ok, `decode failed: ${dec.error}`);
    assert.ok(Array.isArray(dec.result.calendars), 'should have calendars array');
  });

  it('should update a calendar', async () => {
    assert.ok(createdCalendarId);
    const cmdEnum = getProto().lookupEnum('command.Command');
    const Calendar = getProto().lookupType('entity.Calendar');
    const CalendarUpdateRequest = getProto().lookupType('calendar.CalendarUpdateRequest');
    const cal = Calendar.create({
      id: createdCalendarId,
      name: `updated-calendar-${Date.now()}`,
      desc: 'updated by backend test',
    });
    const reqBytes = CalendarUpdateRequest.encode(
      CalendarUpdateRequest.create({ calendar: cal })
    ).finish();
    const res = await client.httpRequest(cmdEnum.values.CALENDAR_UPDATE, reqBytes);
    assert.ok(res.code === 0 || res.code === 200, `code=${res.code}`);

    const dec = safeDecode(getProto(), 'calendar.CalendarUpdateResponse', res.data);
    assert.ok(dec.ok, `decode failed: ${dec.error}`);
    assert.ok(dec.result.calendar, 'should have updated calendar');
    assert.equal(str(dec.result.calendar.id), createdCalendarId);
  });

  it('should create a schedule', async () => {
    assert.ok(createdCalendarId);
    const now = Math.floor(Date.now() / 1000);
    const cmdEnum = getProto().lookupEnum('command.Command');
    const Schedule = getProto().lookupType('entity.Schedule');
    const ScheduleCreateRequest = getProto().lookupType('calendar.ScheduleCreateRequest');
    const schedule = Schedule.create({
      calendar_id: createdCalendarId,
      title: `test-schedule-${Date.now()}`,
      start_time: now,
      end_time: now + 3600,
      type: 0,
    });
    const reqBytes = ScheduleCreateRequest.encode(
      ScheduleCreateRequest.create({ schedule })
    ).finish();
    const res = await client.httpRequest(cmdEnum.values.SCHEDULE_CREATE, reqBytes);
    assert.ok(res.code === 0 || res.code === 200, `code=${res.code}`);

    const dec = safeDecode(getProto(), 'calendar.ScheduleCreateResponse', res.data);
    assert.ok(dec.ok, `decode failed: ${dec.error}`);
    assert.ok(dec.result.schedule, 'should have schedule');
    createdScheduleId = str(dec.result.schedule.id);
  });

  it('should pull schedules by calendar IDs', async () => {
    assert.ok(createdCalendarId);
    const cmdEnum = getProto().lookupEnum('command.Command');
    const SchedulePullByCalendarIdsRequest = getProto().lookupType('calendar.SchedulePullByCalendarIdsRequest');
    const reqBytes = SchedulePullByCalendarIdsRequest.encode(
      SchedulePullByCalendarIdsRequest.create({
        calendar_ids: [createdCalendarId],
        start_time: 0,
        end_time: Math.floor(Date.now() / 1000) + 86400,
      })
    ).finish();
    const res = await client.httpRequest(cmdEnum.values.SCHEDULE_PULL_BY_CALENDAR_IDS, reqBytes);
    assert.ok(res.code === 0 || res.code === 200, `code=${res.code} dataSize=${res.data.byteLength}`);

    const dec = safeDecode(getProto(), 'calendar.SchedulePullByCalendarIdsResponse', res.data);
    assert.ok(dec.ok, `decode failed: ${dec.error}`);
    assert.ok(Array.isArray(dec.result.schedules), 'should have schedules array');
    if (createdScheduleId) {
      const found = dec.result.schedules.find(s => str(s.id) === createdScheduleId);
      assert.ok(found, 'should find our created schedule');
    }
  });

  it('should update a schedule', async () => {
    assert.ok(createdScheduleId);
    const cmdEnum = getProto().lookupEnum('command.Command');
    const Schedule = getProto().lookupType('entity.Schedule');
    const ScheduleUpdateRequest = getProto().lookupType('calendar.ScheduleUpdateRequest');
    const schedule = Schedule.create({
      id: createdScheduleId,
      calendar_id: createdCalendarId,
      title: `updated-schedule-${Date.now()}`,
    });
    const reqBytes = ScheduleUpdateRequest.encode(
      ScheduleUpdateRequest.create({ schedule, with_all: false })
    ).finish();
    const res = await client.httpRequest(cmdEnum.values.SCHEDULE_UPDATE, reqBytes);
    assert.ok(res.code === 0 || res.code === 200, `code=${res.code}`);

    const dec = safeDecode(getProto(), 'calendar.ScheduleUpdateResponse', res.data);
    assert.ok(dec.ok, `decode failed: ${dec.error}`);
    assert.ok(dec.result.schedule, 'should have updated schedule');
  });

  it('should subscribe/unsubscribe a calendar', async () => {
    assert.ok(createdCalendarId);
    const cmdEnum = getProto().lookupEnum('command.Command');
    const CalendarSubscribeRequest = getProto().lookupType('calendar.CalendarSubscribeRequest');

    const subReqBytes = CalendarSubscribeRequest.encode(
      CalendarSubscribeRequest.create({ id: createdCalendarId, subscribe: true })
    ).finish();
    const subRes = await client.httpRequest(cmdEnum.values.CALENDAR_SUBSCRIBE, subReqBytes);
    assert.ok(subRes.code === 0 || subRes.code === 200, `subscribe code=${subRes.code}`);

    const unsubReqBytes = CalendarSubscribeRequest.encode(
      CalendarSubscribeRequest.create({ id: createdCalendarId, subscribe: false })
    ).finish();
    const unsubRes = await client.httpRequest(cmdEnum.values.CALENDAR_SUBSCRIBE, unsubReqBytes);
    assert.ok(unsubRes.code === 0 || unsubRes.code === 200, `unsubscribe code=${unsubRes.code}`);
  });

  it('should delete the schedule', async () => {
    assert.ok(createdScheduleId);
    const cmdEnum = getProto().lookupEnum('command.Command');
    const ScheduleRemoveRequest = getProto().lookupType('calendar.ScheduleRemoveRequest');
    const reqBytes = ScheduleRemoveRequest.encode(
      ScheduleRemoveRequest.create({ id: createdScheduleId })
    ).finish();
    const res = await client.httpRequest(cmdEnum.values.SCHEDULE_REMOVE, reqBytes);
    assert.ok(res.code === 0 || res.code === 200, `code=${res.code}`);
    createdScheduleId = null;
  });

  it('should delete the calendar', async () => {
    assert.ok(createdCalendarId);
    const cmdEnum = getProto().lookupEnum('command.Command');
    const CalendarDeleteRequest = getProto().lookupType('calendar.CalendarDeleteRequest');
    const reqBytes = CalendarDeleteRequest.encode(
      CalendarDeleteRequest.create({ id: createdCalendarId })
    ).finish();
    const res = await client.httpRequest(cmdEnum.values.CALENDAR_DELETE, reqBytes);
    assert.ok(res.code === 0 || res.code === 200, `code=${res.code}`);
    createdCalendarId = null;
  });

});
