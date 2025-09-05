// src/pages/JobDetailPage.tsx
import React, { useState, useEffect } from 'react';
import { useParams, Link, useNavigate } from 'react-router-dom';
import { supabaseStorage } from '../utils/supabaseStorage';
import { Job, Company } from '../types';
import LoadingSpinner from '../components/LoadingSpinner';
import { ArrowLeft, MapPin, Briefcase, DollarSign, Building, ExternalLink, Calendar } from 'lucide-react';

const JobDetailPage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [job, setJob] = useState<Job | null>(null);
  const [company, setCompany] = useState<Company | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadJobDetails = async () => {
      if (!id) {
        setLoading(false);
        return;
      }
      setLoading(true);
      try {
        const jobData = await supabaseStorage.getJobById(id);
        setJob(jobData);
        if (jobData) {
          const companyData = await supabaseStorage.getCompanyById(jobData.company_id);
          setCompany(companyData);
        }
      } catch (error) {
        console.error('Error loading job details:', error);
      } finally {
        setLoading(false);
      }
    };
    loadJobDetails();
  }, [id]);

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <LoadingSpinner message="Loading job details..." size="lg" />
      </div>
    );
  }

  if (!job) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <h2 className="text-2xl font-bold text-gray-900">Job not found</h2>
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
            <div className="flex items-start mb-6">
              {company?.logo_url && (
                <img src={company.logo_url} alt={`${company.name} logo`} className="w-16 h-16 rounded-full mr-4 object-contain border border-gray-200" />
              )}
              <div>
                <h1 className="text-2xl sm:text-3xl font-bold text-gray-900 mb-1">{job.title}</h1>
                {company && (
                  <Link to={`/company/${company.id}`} className="text-blue-600 hover:underline text-lg flex items-center">
                    <Building size={18} className="mr-2" />
                    {company.name}
                  </Link>
                )}
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6 text-gray-700">
              <div className="flex items-center">
                <MapPin size={20} className="mr-3 text-blue-500" />
                <span>{job.location}</span>
              </div>
              <div className="flex items-center">
                <Briefcase size={20} className="mr-3 text-blue-500" />
                <span>{job.experience_level}</span>
              </div>
              <div className="flex items-center">
                <Calendar size={20} className="mr-3 text-blue-500" />
                <span>{job.job_type}</span>
              </div>
              {(job.stipend_min || job.ctc_min) && (
                <div className="flex items-center">
                  <DollarSign size={20} className="mr-3 text-blue-500" />
                  <span>
                    {job.stipend_min && job.stipend_max ? `₹${job.stipend_min} - ₹${job.stipend_max} (Stipend)` : ''}
                    {job.ctc_min && job.ctc_max ? `₹${job.ctc_min} - ₹${job.ctc_max} (CTC)` : ''}
                  </span>
                </div>
              )}
            </div>

            <h2 className="text-xl font-semibold text-gray-900 mb-3">Job Description</h2>
            <p className="text-gray-700 leading-relaxed mb-6 whitespace-pre-line">{job.description}</p>

            {job.skills_required && job.skills_required.length > 0 && (
              <>
                <h2 className="text-xl font-semibold text-gray-900 mb-3">Skills Required</h2>
                <div className="flex flex-wrap gap-2 mb-6">
                  {job.skills_required.map((skill, index) => (
                    <span key={index} className="px-3 py-1 bg-blue-100 text-blue-800 rounded-full text-sm font-medium">
                      {skill}
                    </span>
                  ))}
                </div>
              </>
            )}

            <div className="flex justify-center mt-8">
              <a
                href={job.apply_link}
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center bg-blue-600 text-white px-8 py-3 rounded-lg hover:bg-blue-700 transition-colors text-lg font-medium shadow-lg"
              >
                Apply Now
                <ExternalLink size={20} className="ml-2" />
              </a>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default JobDetailPage;
