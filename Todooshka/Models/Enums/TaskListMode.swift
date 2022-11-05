//
//  TaskListMode.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 31.03.2022.
//
import Foundation

enum TaskListMode: Equatable {
  case completed(date: Date)
  case deleted
  case idea
  case main
  case overdued
  case planned(date: Date)
}
