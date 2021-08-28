//
//  DatabaseReference.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 10.06.2021.
//

import Firebase
import RxSwift
import RxCocoa

extension DatabaseReference {
    
    func rx_observe(eventType: DataEventType = .value) -> Observable<DataSnapshot> {
        
        return Observable.create({ observer in
            
            let observer = self.observe(eventType, with: { data in
                observer.onNext(data)
            }, withCancel: { error in
            //    observer.onError(FirebaseError.custom(message: error.localizedDescription))
            })
            
            return Disposables.create {
                self.removeObserver(withHandle: observer)
            }
        })
    }
    
    /**
     observe single event
     */
    func rx_observeSingleEventOfType(eventType: DataEventType = .value) -> Observable<DataSnapshot> {
        
        return Observable.create({ observer in
            
            self.observeSingleEvent(of: eventType, with: { data in
                observer.onNext(data)
                observer.onCompleted()
            }, withCancel: { error in
            //    observer.onError(FirebaseError.custom(message: error.localizedDescription))
            })
            
            return Disposables.create()
        })
    }
}

