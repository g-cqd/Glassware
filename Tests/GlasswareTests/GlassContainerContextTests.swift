//
//  GlassContainerContextTests.swift
//  GlasswareTests
//

import Testing
@testable import Glassware

@Suite("GlassContainerContext Tests")
struct GlassContainerContextTests {

    @Test("Default context is non-vertical single item with zero inset")
    func defaultValues() {
        let context = GlassContainerContext.default
        #expect(context.itemCount == 1)
        #expect(context.isVerticalEdge == false)
        #expect(context.containerInset == 0)
        #expect(context.isSingleItem)
    }

    @Test("isSingleItem is true only for itemCount == 1")
    func singleItemPredicate() {
        #expect(GlassContainerContext(itemCount: 1, isVerticalEdge: false).isSingleItem)
        #expect(!GlassContainerContext(itemCount: 2, isVerticalEdge: false).isSingleItem)
        #expect(!GlassContainerContext(itemCount: 0, isVerticalEdge: false).isSingleItem)
    }

    @Test("Custom inset is preserved through init")
    func customInset() {
        let context = GlassContainerContext(
            itemCount: 3,
            isVerticalEdge: false,
            containerInset: 4.5
        )
        #expect(context.containerInset == 4.5)
    }

    @Test("Default containerInset is zero when omitted")
    func defaultInsetIsZero() {
        let context = GlassContainerContext(itemCount: 2, isVerticalEdge: true)
        #expect(context.containerInset == 0)
    }

    @Test("Equatable considers all fields")
    func equatable() {
        let a = GlassContainerContext(itemCount: 2, isVerticalEdge: false, containerInset: 3)
        let b = GlassContainerContext(itemCount: 2, isVerticalEdge: false, containerInset: 3)
        let c = GlassContainerContext(itemCount: 2, isVerticalEdge: false, containerInset: 4)
        let d = GlassContainerContext(itemCount: 3, isVerticalEdge: false, containerInset: 3)
        #expect(a == b)
        #expect(a != c)
        #expect(a != d)
    }
}
