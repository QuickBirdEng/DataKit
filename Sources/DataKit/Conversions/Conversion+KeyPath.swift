// Conversion+KeyPath.swift

import Foundation

extension Conversion {

    /// Projects the current target through a key path. Useful when you want to operate on
    /// a component of a composite type (e.g. `.at(\.count)` after a sequence conversion).
    public func at<NewTarget>(
        _ keyPath: KeyPath<Target, NewTarget>
    ) -> Appended<NewTarget> {
        appending { $0[keyPath: keyPath] }
    }

}

extension ReversibleConversion {

    /// Projects through paired forward/backward key paths so the conversion stays
    /// invertible. The two key paths must address types that mutually project to each
    /// other; mismatched paths are a silent footgun.
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

    /// Projects through a key path that has the same source and target type. Use the
    /// `forward`/`backward` flags to apply the projection in only one direction (useful
    /// for asymmetric formats where one side normalizes and the other does not).
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
