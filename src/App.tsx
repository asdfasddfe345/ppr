// src/App.tsx

import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';
import Header from './components/Header';
import HomePage from './pages/HomePage';
import LoginPage from './pages/LoginPage';
import SignupPage from './pages/SignupPage';
import QuestionDetailPage from './pages/QuestionDetailPage';
import DashboardPage from './pages/DashboardPage';
import AdminPage from './pages/AdminPage';
import MaterialsPage from './pages/MaterialsPage';
import CompanyPracticePage from './pages/CompanyPracticePage';
import JobsPage from './pages/JobsPage'; // Import new JobsPage
import JobDetailPage from './pages/JobDetailPage'; // Import new JobDetailPage
import CompanyPage from './pages/CompanyPage'; // Import new CompanyPage
import LoadingSpinner from './components/LoadingSpinner';

// ... (ErrorBoundary, LoadingScreen, ProtectedRoute, AdminRoute components remain the same)

function App() {
  return (
    <ErrorBoundary>
      <AuthProvider>
        <Router>
          <div className="min-h-screen bg-gray-50">
            <Header />
            <Routes>
              {/* Public Routes */}
              <Route path="/" element={<HomePage />} />
              <Route path="/login" element={<LoginPage />} />
              <Route path="/signup" element={<SignupPage />} />

              {/* Jobs Module Routes */}
              <Route path="/jobs" element={
                <ProtectedRoute>
                  <JobsPage />
                </ProtectedRoute>
              } />
              <Route path="/jobs/:id" element={
                <ProtectedRoute>
                  <JobDetailPage />
                </ProtectedRoute>
              } />
              <Route path="/company/:id" element={
                <ProtectedRoute>
                  <CompanyPage />
                </ProtectedRoute>
              } />

              {/* Protected Routes */}
              <Route path="/question/:id" element={
                <ProtectedRoute>
                  <QuestionDetailPage />
                </ProtectedRoute>
              } />

              {/* Practice Routes - All variations */}
              <Route path="/practice" element={
                <ProtectedRoute>
                  <CompanyPracticePage />
                </ProtectedRoute>
              } />
              <Route path="/questions" element={
                <ProtectedRoute>
                  <CompanyPracticePage />
                </ProtectedRoute>
              } />
              <Route path="/practice/:company" element={
                <ProtectedRoute>
                  <CompanyPracticePage />
                </ProtectedRoute>
              } />
              <Route path="/company/:company/practice" element={
                <ProtectedRoute>
                  <CompanyPracticePage />
                </ProtectedRoute>
              } />

              {/* Other Protected Routes */}
              <Route path="/dashboard" element={
                <ProtectedRoute>
                  <DashboardPage />
                </ProtectedRoute>
              } />
              <Route path="/materials" element={
                <ProtectedRoute>
                  <MaterialsPage />
                </ProtectedRoute>
              } />

              {/* Admin Routes */}
              <Route path="/admin" element={
                <AdminRoute>
                  <AdminPage />
                </AdminRoute>
              } />

              {/* Catch-all route for 404s */}
              <Route path="*" element={
                <div className="min-h-screen bg-gray-50 flex items-center justify-center">
                  <div className="text-center">
                    <h1 className="text-4xl font-bold text-gray-900 mb-4">404</h1>
                    <p className="text-gray-600 mb-6">Page not found</p>
                    <button
                      onClick={() => window.location.href = '/'}
                      className="bg-blue-600 text-white px-6 py-3 rounded-lg hover:bg-blue-700 transition-colors"
                    >
                      Go Home
                    </button>
                  </div>
                </div>
              } />
            </Routes>
          </div>
        </Router>
      </AuthProvider>
    </ErrorBoundary>
  );
}

export default App;
