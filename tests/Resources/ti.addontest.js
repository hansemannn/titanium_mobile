/*
 * Appcelerator Titanium Mobile
 * Copyright (c) 2011-Present by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
/* eslint-env mocha */
/* global Ti */
/* eslint no-unused-expressions: "off" */
'use strict';
var should = require('./utilities/assertions'); // eslint-disable-line no-unused-vars

describe('Error', function () {
	it.windowsMissing('JavaScript exceptions', function () {
		var e = {};

		try {
			Ti.API.info(e.test.crash);
			should.fail('Expected to throw JavaScript exception');
		} catch (ex) {
			// has "message" property
			ex.should.have.readOnlyProperty('message').which.is.a.String;
			// has "stack" property
			ex.should.have.readOnlyProperty('stack').which.is.a.String;
			// does not have native stack trace
			ex.should.not.have.property('nativeStack');
		}
	});

	it.windowsMissing('Native exceptions', function () {
		try {
			Ti.Geolocation.accuracy = null;
			should.fail('Expected to throw native exception');
		} catch (ex) {
			// has "message" property
			ex.should.have.readOnlyProperty('message').which.is.a.String;
			// has "stack" property
			ex.should.have.readOnlyProperty('stack').which.is.a.String;
			// has special "nativeStack" property for native stacktrace
			// TODO: Should we make this an array instead? 
			ex.should.have.property('nativeStack').which.is.a.String;
		}
	});

	it.windowsMissing('String (literal) exceptions', function () {
		try {
			throw ('this is my error string'); // eslint-disable-line no-throw-literal
		} catch (ex) {
			ex.should.be.a.String;
			ex.should.equal('this is my error string');
			ex.should.not.have.property('message');
			ex.should.not.have.property('stack');
			ex.should.not.have.property('nativeStack');
		}
	});
});
