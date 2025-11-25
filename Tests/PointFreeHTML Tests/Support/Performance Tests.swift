//
//  Performance Tests.swift
//  pointfree-html
//
//  Top-level performance test suite with serialized execution.
//  All performance tests extend this suite via extension in their respective test files.
//

import Testing

@Suite(
    .serialized,
    .disabled()
)
struct `Performance Tests` {}
