//
//  File.swift
//  
//
//  Created by Paul Kraft on 16.07.23.
//

import Foundation

extension Conversion {

    public func at<NewTarget>(
        _ keyPath: KeyPath<Target, NewTarget>
    ) -> Appended<NewTarget> {
        appending { $0[keyPath: keyPath] }
    }

}

extension ReversibleConversion {

    public func at<NewTarget>(
        _ forward: KeyPath<Target, NewTarget>,
        _ backward: KeyPath<NewTarget, Target>
    ) -> Appended<NewTarget> {
        appending {
            $0.at(forward)
        } revert: {
            $0.at(backward)
        }
    }

    public func at(
        symmetric keyPath: KeyPath<Target, Target>,
        forward: Bool = true,
        backward: Bool = true
    ) -> Appended<Target> {
        appending {
            forward ? $0.at(keyPath) : $0
        } revert: {
            backward ? $0.at(keyPath) : $0
        }
    }

}
