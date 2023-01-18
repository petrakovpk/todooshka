//
//  TaskListMode.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 31.03.2022.
//
import Foundation

enum TaskListMode: Equatable {
  case main
  case overdued
  case idea
  case planned(date: Date)
  case completed(date: Date)
  case deleted
}
