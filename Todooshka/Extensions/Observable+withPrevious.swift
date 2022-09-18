//
//  Observable.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 06.04.2022.
//
import RxFlow
import RxSwift
import RxCocoa

extension ObservableType {
  // withPrevious
  func withPrevious(startWith first: Element) -> Observable<(previous: Element, current: Element)> {
        return scan((first, first)) { ($0.1, $1) }.skip(1)
    }
}
