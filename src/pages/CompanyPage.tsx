// src/pages/CompanyPage.tsx
import React, { useState, useEffect } from 'react';
import { useParams, Link, useNavigate } from 'react-router-dom';
import { supabaseStorage } from '../utils/supabaseStorage';
import { Company, Job } from '../types';
import LoadingSpinner from '../components/LoadingSpinner';
import { ArrowLeft, Globe, Building, MapPin, Briefcase, DollarSign } from 'lucide-react';

const CompanyPage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [company, setCompany] = useState<Company | null>(null);
  const [companyJobs, setCompanyJobs] = useState<Job[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadCompanyDetails = async () => {
      if (!id) {
        setLoading(false);
        return;
      }
      setLoading(true);
      try {
        const companyData = await supabaseStorage.getCompanyById(id);
        setCompany(companyData);
        if (companyData) {
          const jobsData = await supabaseStorage.getJobs({ company_id: id });
          setCompanyJobs(jobsData);
        }
      } catch (error) {
        console.error('Error loading company details:', error);
      } finally {
        setLoading(false);
      }
    };
    loadCompanyDetails();
  }, [id]);

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <LoadingSpinner message="Loading company details..." size="lg" />
      </div>
    );
  }

  if (!company) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <h2 className="text-2xl font-bold text-gray-900">Company not found</h2>
          <button
            onClick={() => navigate('/jobs')}
            className="mt-4 text-blue-600 hover:text-blue-700 flex items-center mx-auto"
          >
            <ArrowLeft size={16} className="mr-1" /> Back to Jobs
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <button
          onClick={() => navigate('/jobs')}
          className="flex items-center space-x-2 text-gray-600 hover:text-blue-600 mb-6 transition-colors p-2 -ml-2 rounded-lg hover:bg-white/50"
        >
          <ArrowLeft size={20} />
          <span>Back to Job Listings</span>
        </button>

        <div className="bg-white rounded-lg shadow-xl overflow-hidden border border-gray-100">
          <div className="p-6 sm:p-8">
            <div className="flex items-center mb-6">
              {company.logo_url && (
                <img src={company.logo_url} alt={`${company.name} logo`} className="w-20 h-20 rounded-full mr-4 object-contain border border-gray-200" />
              )}
              <div>
                <h1 className="text-3xl font-bold text-gray-900 mb-1">{company.name}</h1>
                {company.website_url && (
                  <a href={company.website_url} target="_blank" rel="noopener noreferrer" className="text-blue-600 hover:underline flex items-center text-lg">
                    <Globe size={18} className="mr-2" />
                    Visit Website
                  </a>
                )}
              </div>
            </div>

            <h2 className="text-xl font-semibold text-gray-900 mb-3">About {company.name}</h2>
            <p className="text-gray-700 leading-relaxed mb-6 whitespace-pre-line">
              {company.description || 'No description available.'}
            </p>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6 text-gray-700">
              {company.industry && (
                <div className="flex items-center">
                  <Briefcase size={20} className="mr-3 text-blue-500" />
                  <span>Industry: {company.industry}</span>
                </div>
              )}
              {company.headquarters && (
                <div className="flex items-center">
                  <MapPin size={20} className="mr-3 text-blue-500" />
                  <span>Headquarters: {company.headquarters}</span>
                </div>
              )}
            </div>

            <h2 className="text-xl font-semibold text-gray-900 mb-4">Open Positions at {company.name}</h2>
            {companyJobs.length === 0 ? (
              <p className="text-gray-600">No active job openings at this time. Check back later!</p>
            ) : (
              <div className="space-y-4">
                {companyJobs.map(job => (
                  <div key={job.id} className="bg-gray-50 p-4 rounded-lg border border-gray-200 hover:shadow-md transition-shadow">
                    <Link to={`/jobs/${job.id}`} className="block">
                      <h3 className="text-lg font-semibold text-gray-900 hover:text-blue-600 transition-colors">{job.title}</h3>
                      <div className="flex items-center text-gray-600 text-sm mt-1">
                        <MapPin size={16} className="mr-2" /> {job.location}
                        <span className="mx-2">•</span>
                        <Briefcase size={16} className="mr-2" /> {job.experience_level}
                        {(job.stipend_min || job.ctc_min) && (
                          <>
                            <span className="mx-2">•</span>
                            <DollarSign size={16} className="mr-2" />
                            {job.stipend_min && job.stipend_max ? `₹${job.stipend_min} - ₹${job.stipend_max}` : ''}
                            {job.ctc_min && job.ctc_max ? `₹${job.ctc_min} - ₹${job.ctc_max}` : ''}
                          </>
                        )}
                      </div>
                    </Link>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default CompanyPage;
