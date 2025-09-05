// src/pages/JobsPage.tsx
import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { supabaseStorage } from '../utils/supabaseStorage';
import { Job, Company } from '../types';
import LoadingSpinner from '../components/LoadingSpinner';
import { Search, MapPin, Briefcase, DollarSign, Building, Filter } from 'lucide-react';

const JobsPage: React.FC = () => {
  const [jobs, setJobs] = useState<Job[]>([]);
  const [companies, setCompanies] = useState<Company[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedExperience, setSelectedExperience] = useState('');
  const [selectedJobType, setSelectedJobType] = useState('');
  const [selectedLocation, setSelectedLocation] = useState('');
  const [selectedCompany, setSelectedCompany] = useState('');

  useEffect(() => {
    const loadData = async () => {
      setLoading(true);
      const [jobsData, companiesData] = await Promise.all([
        supabaseStorage.getJobs(),
        supabaseStorage.getCompanies()
      ]);
      setJobs(jobsData);
      setCompanies(companiesData);
      setLoading(false);
    };
    loadData();
  }, []);

  const getCompanyName = (companyId: string) => {
    const company = companies.find(c => c.id === companyId);
    return company ? company.name : 'Unknown Company';
  };

  const getCompanyLogo = (companyId: string) => {
    const company = companies.find(c => c.id === companyId);
    return company?.logo_url || 'https://via.placeholder.com/40x40?text=Co'; // Default placeholder
  };

  const filteredJobs = jobs.filter(job => {
    const matchesSearch = searchTerm === '' ||
                          job.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
                          job.description.toLowerCase().includes(searchTerm.toLowerCase()) ||
                          getCompanyName(job.company_id).toLowerCase().includes(searchTerm.toLowerCase());
    const matchesExperience = selectedExperience === '' || job.experience_level === selectedExperience;
    const matchesJobType = selectedJobType === '' || job.job_type === selectedJobType;
    const matchesLocation = selectedLocation === '' || job.location.toLowerCase().includes(selectedLocation.toLowerCase());
    const matchesCompany = selectedCompany === '' || job.company_id === selectedCompany;

    return matchesSearch && matchesExperience && matchesJobType && matchesLocation && matchesCompany;
  });

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <LoadingSpinner message="Loading jobs..." size="lg" />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-6">Job Listings</h1>

        {/* Search and Filter Section */}
        <div className="bg-white rounded-lg shadow-md p-6 mb-8">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" size={18} />
              <input
                type="text"
                placeholder="Search by title, company, description..."
                className="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
              />
            </div>
            <select
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
              value={selectedExperience}
              onChange={(e) => setSelectedExperience(e.target.value)}
            >
              <option value="">All Experience Levels</option>
              <option value="internship">Internship</option>
              <option value="fresher">Fresher</option>
              <option value="entry">Entry Level</option>
              <option value="0-1yr">0-1 Year</option>
              <option value="1-3yr">1-3 Years</option>
              <option value="3-5yr">3-5 Years</option>
              <option value="5+yr">5+ Years</option>
            </select>
            <select
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
              value={selectedJobType}
              onChange={(e) => setSelectedJobType(e.target.value)}
            >
              <option value="">All Job Types</option>
              <option value="full-time">Full-time</option>
              <option value="part-time">Part-time</option>
              <option value="contract">Contract</option>
              <option value="internship">Internship</option>
            </select>
            <select
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
              value={selectedCompany}
              onChange={(e) => setSelectedCompany(e.target.value)}
            >
              <option value="">All Companies</option>
              {companies.map(company => (
                <option key={company.id} value={company.id}>{company.name}</option>
              ))}
            </select>
          </div>
          <div className="mt-4 flex justify-end">
            <button
              onClick={() => {
                setSearchTerm('');
                setSelectedExperience('');
                setSelectedJobType('');
                setSelectedLocation('');
                setSelectedCompany('');
              }}
              className="px-4 py-2 bg-gray-200 text-gray-700 rounded-md hover:bg-gray-300 transition-colors flex items-center space-x-2"
            >
              <Filter size={18} />
              <span>Clear Filters</span>
            </button>
          </div>
        </div>

        {/* Job Cards */}
        {filteredJobs.length === 0 ? (
          <div className="text-center py-12 bg-white rounded-lg shadow-md">
            <h2 className="text-xl font-semibold text-gray-700">No jobs found matching your criteria.</h2>
            <p className="text-gray-500 mt-2">Try adjusting your filters or search term.</p>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {filteredJobs.map(job => (
              <div key={job.id} className="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-xl transition-shadow duration-300">
                <div className="p-6">
                  <div className="flex items-center mb-4">
                    <img src={getCompanyLogo(job.company_id)} alt={`${getCompanyName(job.company_id)} logo`} className="w-10 h-10 rounded-full mr-3 object-contain border border-gray-200" />
                    <div>
                      <h3 className="text-lg font-semibold text-gray-900">{job.title}</h3>
                      <Link to={`/company/${job.company_id}`} className="text-blue-600 hover:underline text-sm flex items-center">
                        <Building size={14} className="mr-1" />
                        {getCompanyName(job.company_id)}
                      </Link>
                    </div>
                  </div>
                  <div className="flex items-center text-gray-600 text-sm mb-2">
                    <MapPin size={16} className="mr-2" /> {job.location}
                  </div>
                  <div className="flex items-center text-gray-600 text-sm mb-2">
                    <Briefcase size={16} className="mr-2" /> {job.experience_level}
                  </div>
                  {(job.stipend_min || job.ctc_min) && (
                    <div className="flex items-center text-gray-600 text-sm mb-4">
                      <DollarSign size={16} className="mr-2" />
                      {job.stipend_min && job.stipend_max ? `₹${job.stipend_min} - ₹${job.stipend_max} (Stipend)` : ''}
                      {job.ctc_min && job.ctc_max ? `₹${job.ctc_min} - ₹${job.ctc_max} (CTC)` : ''}
                    </div>
                  )}
                  <p className="text-gray-700 text-sm mb-4 line-clamp-3">{job.description}</p>
                  <Link
                    to={`/jobs/${job.id}`}
                    className="inline-block bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 transition-colors text-sm font-medium"
                  >
                    View Details
                  </Link>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export default JobsPage;
